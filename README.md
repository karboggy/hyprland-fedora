# Hyprland - Fedora (stable & nightly builds)
This experimental repository use [GitHub Actions CI](https://github.com/karboggy/hyprland-fedora/actions) to automatically build stable and nightly version of [Hyprland](https://github.com/hyprwm/Hyprland.git), [quickshell](https://git.outfoxxed.me/quickshell/quickshell) & cie packages for Fedora (.rpm). Only for advanced users!

For regular Fedora users, I recommend to use COPR, for example:
- https://github.com/solopasha/hyprlandRPM
- https://github.com/LionHeartP/hyprlandRPM


# How to install the latest stable?
Run `./update-latest.sh stable` 

# How to install the latest nightly?
Run `./update-latest.sh nightly` 

# How to install a specific gereated package?
Download the zip file from [the latest generated RPM packages](https://github.com/karboggy/hyprland-fedora/releases/latest) (Asset section).
```shell
# Unzip it
unzip -d hyprland-fedora-rpms 2025-12-29_hyprland-fedora-nightly-rpms.zip

# Install/Update RPM packages
sudo dnf install hyprland-fedora-rpms/*.rpm
```

# How to build myself the RPM packages?
Requirements: `docker`
```shell
# Clone this repository
git clone https://github.com/karboggy/hyprland-fedora.git

# Generate nightly RPM packages
cd hyprland-fedora && ./build-locally.sh nightly

# Generate stable RPM packages from versions/stable.env
./build-locally.sh stable

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
**Fedora 43** (x86_64):
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
 - [x] misc: Script to locally build packages
 - [x] ci: Github CI pipeline to build nightly
 - [x] misc: Script to update from latest build done by Github
 - [ ] quickshell: enable cpptrace feature (-DVENDOR_CPPTRACE=ON)
 - [x] ci: Add Github CI pipeline to build latest release of each project (kind of)
 - [ ] ci: Allow dnf install from this Githuv repository (or COPR ?)
