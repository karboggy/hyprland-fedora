# Hyprland - Fedora (Nightly builds)
This experimental repository use [GitHub Actions CI](https://github.com/karboggy/hyprland-fedora/actions) to automatically build nightly version of [Hyprland](https://github.com/hyprwm/Hyprland.git), [quickshell](https://git.outfoxxed.me/quickshell/quickshell) & cie packages for Fedora (.rpm). Only for advanced users that want to live on the 'main' branch!

For regular Fedora users, I recommend to use COPR, for example:
- https://github.com/solopasha/hyprlandRPM
- https://github.com/LionHeartP/hyprlandRPM

# How to install the generated RPM packages?
Download the zip file from [the latest generated RPM packages](https://github.com/karboggy/hyprland-fedora/releases/latest) (Asset section).
```shell
# Unzip it
unzip -d hyprland-fedora-rpms 2025-12-29_hyprland-fedora-rpms.zip

# Install/Update RPM packages
sudo dnf install hyprland-fedora-rpms/*.rpm
```

... or just run the `update.sh` from this repository!

# How to build myself the RPM packages?
Requirements: `docker`
```shell
# Clone this repository
git clone https://github.com/karboggy/hyprland-fedora.git

# Generate the RPM packages
cd hyprland-fedora && ./process.sh

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

