import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import runpy
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('publish_dnf', 'scripts/publish-dnf.py')
publisher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(publisher)
CLEANUP = str(Path('scripts/cleanup-nightly.py').resolve())


class RepositoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        previous = Path.cwd()
        os.chdir(self.temp.name)
        self.addCleanup(os.chdir, previous)
        Path('keys').mkdir()
        Path('keys/rpm-signing-public.asc').write_text('public key')
        self.env = patch.dict(os.environ, {
            'GITHUB_REPOSITORY': 'owner/repo', 'PAGES_URL': 'https://owner.github.io/repo',
            'GITHUB_OUTPUT': str(Path('outputs').resolve())})
        self.env.start()
        self.addCleanup(self.env.stop)
        self.rpm_name = 'hyprland-0.56.2-1.fc44.x86_64.rpm'
        self.payload = b'signed rpm fixture'
        self.manifest = {'schema': 1, 'packages': {
            self.rpm_name: hashlib.sha256(self.payload).hexdigest()}}
        self.release = self.make_release('2026-09-27_fedora44_nightly_hyprland-0.56.2', 3)
        self.release['assets'] = [
            {'name': n, 'browser_download_url': 'https://example.org/' + n}
            for n in ['dnf-ready.json', self.rpm_name]]

    def make_release(self, tag, number):
        return {'tag_name': tag, 'id': number, 'published_at': f'2026-09-{number:02d}',
                'draft': False, 'prerelease': False, 'assets': []}

    def download(self, url, destination):
        destination.write_bytes(json.dumps(self.manifest).encode()
                                if url.endswith('dnf-ready.json') else self.payload)

    def command(self, *args):
        if args[0] == 'rpmkeys':
            return 'fixture: digests signatures OK' if '--checksig' in args else ''
        if args[0] == 'rpm':
            return 'x86_64'
        if args[0] == 'createrepo_c':
            base = args[args.index('--baseurl') + 1]
            target = Path(args[args.index('--outputdir') + 1]) / 'repodata'
            target.mkdir()
            xml = (f'<metadata xmlns="http://linux.duke.edu/metadata/common"><package>'
                   f'<location xml:base="{base}" href="{self.rpm_name}" />'
                   '</package></metadata>')
            (target / 'checksum-primary.xml.gz').write_bytes(gzip.compress(xml.encode()))
            return ''
        raise AssertionError(args)

    def build(self, available=None):
        with patch.object(publisher, 'releases', return_value=available or [self.release]), \
             patch.object(publisher, 'download', side_effect=self.download), \
             patch.object(publisher, 'run', side_effect=self.command):
            publisher.build()

    def test_metadata_only_and_release_protection(self):
        self.build()
        site = Path('out/pages')
        self.assertFalse(list(site.rglob('*.rpm')))
        self.assertEqual(json.loads((site / 'releases.json').read_text()),
                         [self.release['tag_name']])
        repo = (site / 'hyprland-fedora.repo').read_text()
        self.assertIn('$releasever/$basearch/', repo)
        self.assertIn('gpgcheck=1', repo)
        self.assertIn('metadata_expire=1h', repo)

    def test_corrupt_rpm_blocks_publication(self):
        self.manifest['packages'][self.rpm_name] = '0' * 64
        with self.assertRaisesRegex(ValueError, 'Checksum mismatch'):
            self.build()
        self.assertFalse(Path('outputs').exists())

    def test_missing_asset_blocks_publication(self):
        self.release['assets'].pop()
        with self.assertRaisesRegex(ValueError, 'do not match'):
            self.build()

    def test_wrong_signing_key_blocks_publication(self):
        original = self.command
        def command(*args):
            if '--checksig' in args:
                return 'fixture: digests SIGNATURES NOT OK'
            return original(*args)
        with patch.object(publisher, 'releases', return_value=[self.release]), \
             patch.object(publisher, 'download', side_effect=self.download), \
             patch.object(publisher, 'run', side_effect=command):
            with self.assertRaisesRegex(ValueError, 'Invalid signature'):
                publisher.build()

    def test_empty_or_legacy_releases_do_not_replace_pages(self):
        legacy = self.make_release('2026-09-27_fedora44_nightly_old', 3)
        with self.assertRaisesRegex(ValueError, 'No signed releases'):
            self.build([legacy])

    def test_cleanup_preserves_two_per_fedora_stable_and_protected(self):
        releases = [self.make_release(f'2026-09-{n:02d}_fedora{f}_nightly_hyprland', n)
                    for f in (43, 44) for n in (1, 2, 3)]
        stable = self.make_release('2026-09-01_fedora44_stable_hyprland', 1)
        releases.append(stable)
        protected = releases[3]['tag_name']
        with patch.dict(os.environ, {'PROTECTED_TAGS': json.dumps([protected])}), \
             patch('subprocess.check_output', return_value=json.dumps([releases])), \
             patch('subprocess.run') as delete:
            runpy.run_path(CLEANUP, run_name='__main__')
        self.assertEqual(delete.call_count, 1)
        self.assertEqual(delete.call_args.args[0][3], releases[0]['tag_name'])


if __name__ == '__main__':
    unittest.main()
