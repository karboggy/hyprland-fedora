# Hyprland - Fedora
Hyprland automatically built by GitHub Actions for Fedora

# Supported version
- Fedora 43
    - Hyprland v0.52.1

# How to use
```shell
# 1. create the docker image
#  - clone projects
#  - make binaries from sources
#  - craft .rpm files
# 2. bring back binaries on the host
./process.sh
```

# Tips
```shell
# List all packages from a copr repo (e.g: solopasha:hyprland)
dnf list --available --repo=copr\* | grep "copr:copr.fedorainfracloud.org:solopasha:hyprland"

# List all installed package from a copr repo
dnf list --installed | grep solopasha:hyprland

# Remove all installed package from a copr repo
dnf remove $(dnf list --installed | grep solopasha:hyprland | awk '{print $1}' | cut -d. -f1)

# Install built RPMS :
cd ./out/packages/rpms/x86_64
sudo dnf install aquamarine*.rpm hyprcursor*.rpm hyprgraphics*.rpm hypridle*.rpm hyprland*.rpm hyprlang*.rpm hyprlock*.rpm hyprshot*.rpm hyprutils*.rpm uwsm*.rpm xdg-desktop-portal-hyprland*.rpm
```

# Sources
- https://github.com/hyprwm/Hyprland.git
- https://github.com/solopasha/hyprlandRPM.git
- https://github.com/LionHeartP/hyprlandRPM