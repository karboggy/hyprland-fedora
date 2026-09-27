#!/usr/bin/env bash
set -euo pipefail
: "${RPM_SIGNING_PRIVATE_KEY:?Missing signing key}"
: "${RPM_SIGNING_PASSPHRASE:?Missing signing passphrase}"
work=$(mktemp -d)
trap 'gpgconf --kill gpg-agent || true; rm -rf "$work"' EXIT
export GNUPGHOME="$work/gnupg"
mkdir -m 700 "$GNUPGHOME"
printf '%s' "$RPM_SIGNING_PRIVATE_KEY" | gpg --batch --import
printf '%s' "$RPM_SIGNING_PASSPHRASE" > "$work/passphrase"
chmod 600 "$work/passphrase"
unset RPM_SIGNING_PRIVATE_KEY RPM_SIGNING_PASSPHRASE
fingerprint=$(gpg --show-keys --with-colons keys/rpm-signing-public.asc | awk -F: '$1 == "fpr" {print $10; exit}')
[[ -n "$fingerprint" ]]
cat > "$work/gpg-sign" <<WRAPPER
#!/usr/bin/env bash
exec /usr/bin/gpg --batch --pinentry-mode loopback --passphrase-file "$work/passphrase" "\$@"
WRAPPER
chmod 700 "$work/gpg-sign"
mkdir "$work/rpmdb"
rpmkeys --dbpath "$work/rpmdb" --import keys/rpm-signing-public.asc
# GitHub sanitizes special characters in release asset names (e.g. RPM's ^).
# Normalize filenames before creating the checksum manifest.
python3 - <<'PYTHON'
import re
from pathlib import Path
for path in Path('out/rpms/x86_64').glob('*.rpm'):
    target = path.with_name(re.sub(r'[^A-Za-z0-9._-]', '_', path.name))
    if target != path:
        if target.exists():
            raise ValueError(f'RPM filename collision: {target.name}')
        path.rename(target)
PYTHON
shopt -s nullglob
rpms=(out/rpms/x86_64/*.rpm)
(( ${#rpms[@]} > 0 ))
for rpm_file in "${rpms[@]}"; do
    rpmsign --define "_gpg_name $fingerprint" --define "__gpg $work/gpg-sign" --addsign "$rpm_file"
    result=$(rpmkeys --dbpath "$work/rpmdb" --checksig "$rpm_file")
    [[ "$result" == *"signatures OK"* ]] || { echo "$result" >&2; exit 1; }
done
python3 - <<'PY'
import hashlib, json
from pathlib import Path
packages = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(Path('out/rpms/x86_64').glob('*.rpm'))}
Path('out/dnf-ready.json').write_text(json.dumps({'schema': 1, 'packages': packages}, indent=2) + '\n')
PY
