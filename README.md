# Hyprland - Fedora (stable & nightly builds)
This experimental repository use [GitHub Actions CI](https://github.com/karboggy/hyprland-fedora/actions) to automatically build stable and nightly version of [Hyprland](https://github.com/hyprwm/Hyprland.git), [quickshell](https://git.outfoxxed.me/quickshell/quickshell) & cie packages for Fedora (.rpm). Only for advanced users!

For regular Fedora users, I recommend to use COPR, for example:
- https://github.com/solopasha/hyprlandRPM
- https://github.com/LionHeartP/hyprlandRPM

Supported Fedora versions: 43 and 44. Fedora 45 builds are experimental.

# Install or update using the DNF repository

The DNF repository serves metadata from GitHub Pages and downloads signed RPMs
from GitHub Releases. Each configured Fedora version has separate stable and nightly repositories.
The repository becomes available after the first successful signed build and Pages deployment.

## Configure the repository and choose a channel

For both a fresh installation and an existing ZIP-based installation, install
the repository configuration once:

```shell
sudo curl --fail --location \
  https://karboggy.github.io/hyprland-fedora/hyprland-fedora.repo \
  --output /etc/yum.repos.d/hyprland-fedora.repo
```

Choose your channel before installing or synchronizing packages. Stable is enabled
by default in the repository file; nightly is disabled. These DNF5 commands also
override any previous channel selection. Enable only one channel.

For stable:

```shell
sudo dnf config-manager setopt hyprland-fedora-nightly.enabled=0 hyprland-fedora-stable.enabled=1
```

For nightly:

```shell
sudo dnf config-manager setopt hyprland-fedora-stable.enabled=0 hyprland-fedora-nightly.enabled=1
```

## Fresh installation

After configuring the repository and choosing a channel:

```shell
sudo dnf makecache --refresh
sudo dnf install hyprland
```

Install any additional tools you want, such as `hyprlock`, `hypridle` or `quickshell`.
Installing `hyprland` installs its dependencies, not every package in this repository.

## Switch existing ZIP-installed packages to the DNF repository

Keep your installed RPMs: no uninstallation is needed. After configuring the
repository and choosing a channel, preview synchronization on your current Fedora
version:

```shell
sudo dnf --refresh --assumeno distro-sync
```

`--assumeno` automatically declines the transaction; the final "Operation aborted"
message is expected and no packages are changed. Check that your Hyprland packages
come from `hyprland-fedora-stable` or `hyprland-fedora-nightly` and review any removals.

If the proposed transaction is suitable, run it without `--assumeno`:

```shell
sudo dnf --refresh distro-sync
```

`distro-sync` can upgrade, downgrade or reinstall packages to match the selected
repositories. Without package names, it synchronizes the whole system, including
Fedora updates. Some ZIP-installed RPMs may be reinstalled at the same version
from our signed repository. This is also the procedure for switching channels.

Restart your session (or reboot after system updates) and verify that Hyprland
works before starting a Fedora version upgrade.

## Signing key verification

DNF imports the public signing key when first installing signed packages. Verify
its fingerprint against `keys/rpm-signing-public.asc`:

```text
3A41 F19C DA42 B4AB F1F4 5249 A1C9 9FD4 7A51 1582
```

## Subsequent updates and Fedora version upgrades

Once configured, normal updates include these packages:

```shell
sudo dnf upgrade --refresh
```

For a Fedora 43 to 44 migration, ensure that the selected channel has a complete Fedora
44 repository before preparing the offline upgrade:

```shell
sudo dnf upgrade --refresh
sudo dnf system-upgrade download --releasever=44
# Review the transaction; reboot only after preparation succeeds.
sudo dnf system-upgrade reboot
```

The repository URL uses `$releasever`, so DNF can replace the Fedora 43 packages
with Fedora 44 builds in the same transaction. This still requires compatible
package dependencies; repository publication alone does not guarantee every upgrade resolves.

# Repository publication (maintainers)

1. In Settings → Pages, select **GitHub Actions** as the source.
2. Add Actions secrets `RPM_SIGNING_PRIVATE_KEY` (armored private key) and
   `RPM_SIGNING_PASSPHRASE`; commit only `keys/rpm-signing-public.asc`.
3. Run **Stable** and **Nightly** on `main` to initialize the repositories for all configured Fedora versions.
   If today's release tag already exists, the build preserves it; a new release
   tag (normally the next day's build) is needed to add the signed RPM assets.
4. Check **Publish DNF repository** and the deployed `releases.json` to see which
   release backs each repository. The publication workflow can also be run manually
   to retry a failed deployment without rebuilding RPMs.

Fedora targets are defined once in `versions/fedora.json`: the version number,
whether build failures are tolerated while experimental, and which nightly target
is marked as the latest GitHub release (currently Fedora 44). CI matrices, local
scripts, metadata publication and cleanup use this file.

Both build workflows accept an optional `fedora_version` input: `all` (default)
or a configured version such as `45`. To test Fedora 45 alone, run **Stable** or
**Nightly** manually with `fedora_version=45`. Scheduled nightly builds include
all configured targets. Experimental Fedora 45 failures do not block publication
of successful Fedora 43/44 builds; inspect the Fedora 45 job itself to assess its
result. Fedora 45 repositories become available only after signed RPMs are built
successfully, and session compatibility still needs testing on Fedora 45.

Release descriptions contain a short build summary; RPM assets provide the package
list. Stable refs remain in `versions/stable.env` rather than being duplicated in
every release description. These descriptions apply to newly created releases;
existing published releases are preserved.

Builds sign and verify every RPM, then upload the ZIP, individual RPMs and a
`dnf-ready.json` checksum manifest. Releases are created as drafts and published
only after all assets upload successfully. Older ZIP-only releases are not selected
for the DNF repository. A channel with no signed release yet is omitted until its
first signed build; an entirely empty deployment is rejected.

The Pages workflow serializes publications, verifies RPM checksums and signatures,
then deploys metadata for every available Fedora/channel combination. It publishes
no RPM binaries to Pages. Metadata generation or deployment failures prevent cleanup.
RPM signatures are checked by DNF (`gpgcheck=1`); repository metadata is served over
HTTPS and is not separately GPG-signed (`repo_gpgcheck=0`).

After successful deployment, cleanup keeps the two newest published nightly releases
per Fedora version and protects every release referenced by that deployment. All
stable releases remain available. Releases and their tags are deleted together;
orphan tags without releases are left alone. Metadata expires after one hour;
multiple builds within that hour can still invalidate an older client cache. Refresh
it with `dnf clean metadata` if needed.

Local validation of repository selection, failure handling and retention:

```shell
python3 -m unittest discover -s tests -v
# Requires rpm, gnupg and createrepo_c; uses a disposable test key.
bash tests/smoke-signing.sh
```

# How to install the latest stable?
Run `./update-latest.sh stable 44`

# How to install the latest nightly?
Run `./update-latest.sh nightly 44`

# How to install a specific gereated package?
Download the zip file from [the latest generated RPM packages](https://github.com/karboggy/hyprland-fedora/releases/latest) (Asset section).
```shell
# Unzip it
unzip -d hyprland-fedora-rpms 2025-12-29_hyprland-fedora44-nightly-rpms.zip

# Install/Update RPM packages
sudo dnf install hyprland-fedora-rpms/*.rpm
```

# How to build myself the RPM packages?
Requirements: `docker`, `python3`

Use `43`, `44` or `45` as the Fedora version argument. This must match the Fedora
version where you will install the RPMs; Fedora 44 RPMs will not install on
Fedora 43.

```shell
# Clone this repository
git clone https://github.com/karboggy/hyprland-fedora.git

# Generate nightly RPM packages for your Fedora version  (43, 44 or 45)
cd hyprland-fedora && ./build-locally.sh nightly 43

# Generate stable RPM packages from versions/stable.env for your Fedora version (43, 44 or 45)
./build-locally.sh stable 43

# Install/Update RPM packages
sudo dnf install out/rpms/x86_64/*.rpm
```

# Tips
```shell
# List all packages from a copr repo (e.g: solopasha:hyprland)
dnf list --available --repo=copr\* | grep "copr:copr.fedorainfracloud.org:solopasha:hyprland"

# List all installed package from a copr repo
dnf list --installed | grep solopasha:hyprland

# Remove all installed package from a copr repo
dnf remove $(dnf list --installed | grep solopasha:hyprland | awk '{print $1}' | cut -d. -f1)

# Remove a copr repo
sudo dnf copr remove solopasha/hyprland

# How to find which fedora packges provides a file (e.g libpci.so)
dnf provides "*/libpci*"
```

# List of packages
**Fedora 43 / Fedora 44 / Fedora 45 (experimental)** (x86_64):
 - aquamarine
 - hyprcursor
 - hyprgraphics
 - hypridle
 - hyprland
 - hyprland-guiutils
 - hyprland-protocols
 - hyprlang
 - hyprlauncher
 - hyprlock
 - hyprpaper
 - hyprpicker
 - hyprpolkitagent
 - hyprland-qt-support
 - hyprqt6engine
 - hyprshot
 - hyprsunset
 - hyprsysteminfo
 - hyprtoolkit
 - hyprutils
 - hyprwayland-scanner
 - hyprwire
 - quickshell
 - uwsm
 - xdg-desktop-portal-hyprland

# Roadmap
 - [x] linux: Support fedora 43
 - [x] linux: Support fedora 44
 - [x] misc: Script to locally build packages
 - [x] ci: Github CI pipeline to build nightly
 - [x] misc: Script to update from latest build done by Github
 - [x] ci: Add Github CI pipeline to build latest release of each project (kind of)
 - [ ] quickshell: enable cpptrace feature (-DVENDOR_CPPTRACE=ON)
 - [x] ci: Publish a DNF repository using GitHub Pages metadata and signed Release RPMs
