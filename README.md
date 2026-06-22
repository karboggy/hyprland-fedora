# Hyprland - Fedora (stable & nightly builds)
This experimental repository use [GitHub Actions CI](https://github.com/karboggy/hyprland-fedora/actions) to automatically build stable and nightly version of [Hyprland](https://github.com/hyprwm/Hyprland.git), [quickshell](https://git.outfoxxed.me/quickshell/quickshell) & cie packages for Fedora (.rpm). Only for advanced users!

For regular Fedora users, I recommend to use COPR, for example:
- https://github.com/solopasha/hyprlandRPM
- https://github.com/LionHeartP/hyprlandRPM

Supported Fedora versions: 43 and 44.

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
Requirements: `docker`

Use `43` or `44` as the Fedora version argument. This must match the Fedora
version where you will install the RPMs; Fedora 44 RPMs will not install on
Fedora 43.

```shell
# Clone this repository
git clone https://github.com/karboggy/hyprland-fedora.git

# Generate nightly RPM packages for your Fedora version  (43 or 44)
cd hyprland-fedora && ./build-locally.sh nightly 43

# Generate stable RPM packages from versions/stable.env for your Fedora version (43 or 44)
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
**Fedora 43 / Fedora 44** (x86_64):
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
 - [ ] ci: Allow dnf install from this Githuv repository (or COPR ?)
