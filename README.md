# Hyprland - Fedora
Hyprland automatically built by GitHub Actions for Fedora

# Supported version
- Fedora 43
    - Hyprland v0.52.1

# How to use
```shell
# create the docker image (will clone and build all projects)
./build.sh

# bring back binaries on the host
./copy.sh

```

# Tips
```shell
# List all packages from a copr repo (e.g: solopasha:hyprland)
dnf list --available --repo=copr\* | grep "copr:copr.fedorainfracloud.org:solopasha:hyprland"
```

# Sources
- https://github.com/hyprwm/Hyprland.git
- https://github.com/solopasha/hyprlandRPM.git
- https://github.com/LionHeartP/hyprlandRPM