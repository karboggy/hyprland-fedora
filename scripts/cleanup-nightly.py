#!/usr/bin/env python3
"""Keep two nightly releases per Fedora plus any release referenced on Pages."""
import json
import os
import re
import subprocess
from fedora_versions import SUPPORTED_VERSIONS

def run(*args):
    return subprocess.check_output(args, text=True).strip()

repo = os.environ['GITHUB_REPOSITORY']
protected = set(json.loads(os.environ['PROTECTED_TAGS']))
if not protected:
    raise ValueError('Missing published release protection list')
pages = json.loads(run('gh', 'api', '--paginate', '--slurp', f'repos/{repo}/releases?per_page=100'))
releases = [r for page in pages for r in page if not r['draft'] and not r['prerelease']]
for fedora in SUPPORTED_VERSIONS:
    def matches(tag):
        if '_stable_' in tag or tag.startswith('stable_'):
            return False
        return (f'_fedora{fedora}_nightly_' in tag or
                (fedora == 43 and ('_nightly_hyprland-' in tag or
                 re.match(r'^\d{4}-\d{2}-\d{2}_hyprland-', tag))))
    candidates = sorted([r for r in releases if matches(r['tag_name'])],
                        key=lambda r: (r['published_at'], r['id']), reverse=True)
    for release in candidates[2:]:
        tag = release['tag_name']
        if tag in protected:
            print(f'Keeping release referenced on Pages: {tag}')
            continue
        print(f'Deleting old Fedora {fedora} nightly: {tag}')
        subprocess.run(['gh', 'release', 'delete', tag, '--repo', repo,
                        '--yes', '--cleanup-tag'], check=True)

