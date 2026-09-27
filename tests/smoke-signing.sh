#!/usr/bin/env bash
# Exercise real GPG/RPM tools with a disposable key, never the production secrets.
set -euo pipefail
script_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
mkdir -p keys out/rpms/x86_64 keygen rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
chmod 700 keygen
export GNUPGHOME="$work/keygen"
export RPM_SIGNING_PASSPHRASE='disposable-ci-test-passphrase'
gpg --batch --pinentry-mode loopback --passphrase "$RPM_SIGNING_PASSPHRASE" \
    --quick-generate-key 'Disposable RPM test <test@example.invalid>' rsa2048 sign 1d
gpg --armor --export > keys/rpm-signing-public.asc
RPM_SIGNING_PRIVATE_KEY=$(gpg --batch --pinentry-mode loopback \
    --passphrase "$RPM_SIGNING_PASSPHRASE" --armor --export-secret-keys)
export RPM_SIGNING_PRIVATE_KEY
cat > rpmbuild/SPECS/hyprland.spec <<'SPEC'
Name: hyprland
Version: 1.0
Release: 1
Summary: Disposable signing test
License: MIT
BuildArch: x86_64
%description
Disposable signing test.
%install
mkdir -p %{buildroot}/usr/share/hyprland-test
echo test > %{buildroot}/usr/share/hyprland-test/fixture
%files
/usr/share/hyprland-test/fixture
SPEC
rpmbuild --define "_topdir $work/rpmbuild" -bb rpmbuild/SPECS/hyprland.spec
cp rpmbuild/RPMS/x86_64/*.rpm out/rpms/x86_64/
bash "$script_root/scripts/sign-rpms.sh"
mkdir -p metadata
createrepo_c --general-compress-type gz \
    --baseurl https://github.com/example/test/releases/download/test/ \
    --outputdir metadata out/rpms/x86_64
python3 - <<'PY'
import gzip, json
from pathlib import Path
import xml.etree.ElementTree as ET
manifest = json.loads(Path('out/dnf-ready.json').read_text())
primary = next(Path('metadata/repodata').glob('*-primary.xml.gz'))
root = ET.fromstring(gzip.decompress(primary.read_bytes()))
locations = root.findall('.//{http://linux.duke.edu/metadata/common}location')
assert len(locations) == 1
assert locations[0].attrib['href'] in manifest['packages']
assert locations[0].attrib['{http://www.w3.org/XML/1998/namespace}base'] == \
    'https://github.com/example/test/releases/download/test/'
print('Real RPM signing and metadata smoke test passed')
PY
gpgconf --kill gpg-agent
