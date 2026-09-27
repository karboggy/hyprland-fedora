#!/usr/bin/env python3
"""Build Pages metadata from complete, signed release assets; never publish RPMs on Pages."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from fedora_versions import SUPPORTED_VERSIONS
import tempfile
from urllib.parse import quote
import xml.etree.ElementTree as ET
import gzip


def run(*args):
    return subprocess.check_output(args, text=True).strip()


def releases():
    pages = json.loads(run('gh', 'api', '--paginate', '--slurp',
                          f'repos/{os.environ["GITHUB_REPOSITORY"]}/releases?per_page=100'))
    return [r for page in pages for r in page if not r['draft'] and not r['prerelease']]


def download(url, destination):
    subprocess.run(['curl', '--fail', '--location', '--retry', '3',
                    '--silent', '--show-error', '--output', str(destination), url], check=True)


def build():
    available = releases()
    site = Path('out/pages')
    site.mkdir(parents=True, exist_ok=True)
    shutil.copyfile('keys/rpm-signing-public.asc', site / 'rpm-signing-public.asc')
    selected = []
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        db = work / 'rpmdb'
        db.mkdir()
        run('rpmkeys', '--dbpath', str(db), '--import', 'keys/rpm-signing-public.asc')
        for channel in ('stable', 'nightly'):
            for fedora in SUPPORTED_VERSIONS:
                candidates = sorted(
                    [r for r in available if f'_fedora{fedora}_{channel}_' in r['tag_name']
                     and any(a['name'] == 'dnf-ready.json' for a in r['assets'])],
                    key=lambda r: (r['published_at'], r['id']), reverse=True)
                if not candidates:
                    print(f'No signed release yet for {channel} Fedora {fedora}; skipping.')
                    continue
                release = candidates[0]
                assets = {a['name']: a for a in release['assets']}
                package_dir = work / f'{channel}-{fedora}'
                package_dir.mkdir()
                manifest_path = package_dir / 'dnf-ready.json'
                download(assets['dnf-ready.json']['browser_download_url'], manifest_path)
                manifest = json.loads(manifest_path.read_text())
                packages = manifest['packages']
                if manifest['schema'] != 1 or not packages:
                    raise ValueError('Invalid release manifest')
                if set(packages) != {name for name in assets if name.endswith('.rpm')}:
                    raise ValueError('Release RPM assets do not match manifest')
                if not any(re.fullmatch(r'hyprland-[0-9].*\.rpm', name) for name in packages):
                    raise ValueError('Main Hyprland RPM missing')
                for name, checksum in packages.items():
                    if Path(name).name != name or not name.endswith('.rpm'):
                        raise ValueError('Invalid RPM asset name')
                    path = package_dir / name
                    download(assets[name]['browser_download_url'], path)
                    if hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                        raise ValueError(f'Checksum mismatch: {name}')
                    result = run('rpmkeys', '--dbpath', str(db), '--checksig', str(path))
                    if 'signatures OK' not in result:
                        raise ValueError(f'Invalid signature: {result}')
                    if run('rpm', '-qp', '--qf', '%{ARCH}', str(path)) not in ('x86_64', 'noarch'):
                        raise ValueError(f'Unexpected architecture: {name}')
                target = site / channel / 'fedora' / str(fedora) / 'x86_64'
                target.mkdir(parents=True)
                baseurl = ('https://github.com/' + os.environ['GITHUB_REPOSITORY']
                           + '/releases/download/' + quote(release['tag_name'], safe='') + '/')
                run('createrepo_c', '--general-compress-type', 'gz', '--baseurl', baseurl, '--outputdir', str(target), str(package_dir))
                # Check that DNF will fetch RPMs from Releases, not Pages.
                primary = next((target / 'repodata').glob('*-primary.xml.gz'))
                root = ET.fromstring(gzip.decompress(primary.read_bytes()))
                locations = root.findall('.//{http://linux.duke.edu/metadata/common}location')
                if len(locations) != len(packages) or any(
                    loc.attrib.get('{http://www.w3.org/XML/1998/namespace}base') != baseurl
                    or loc.attrib['href'] not in packages for loc in locations
                ):
                    raise ValueError('Generated RPM URLs do not match release assets')
                selected.append(release['tag_name'])
                print(f'Published metadata for {release["tag_name"]}')
    if not selected:
        raise ValueError('No signed releases available; refusing empty Pages publication')
    (site / 'releases.json').write_text(json.dumps(selected, indent=2) + '\n')
    base = os.environ['PAGES_URL'].rstrip('/')
    repo = []
    for channel in ('stable', 'nightly'):
        repo.append(f'''[hyprland-fedora-{channel}]
name=Hyprland Fedora {channel}
baseurl={base}/{channel}/fedora/$releasever/$basearch/
enabled={int(channel == 'stable')}
gpgcheck=1
repo_gpgcheck=0
gpgkey={base}/rpm-signing-public.asc
metadata_expire=1h
skip_if_unavailable=0
''')
    (site / 'hyprland-fedora.repo').write_text('\n'.join(repo))
    (site / 'index.html').write_text(
        '<!doctype html><title>Hyprland Fedora RPM repository</title>'
        '<h1>Hyprland Fedora RPM repository</h1>'
        '<p><a href="hyprland-fedora.repo">DNF configuration</a></p>'
        '<p><a href="rpm-signing-public.asc">RPM signing public key</a></p>')
    with open(os.environ['GITHUB_OUTPUT'], 'a') as output:
        output.write('protected_tags=' + json.dumps(selected) + '\n')


if __name__ == '__main__':
    build()
