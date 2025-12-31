#!/usr/bin/env bash
set -euxo pipefail

# Configuration
TARGET_DOWNLOAD_ZIP=/tmp/hyprland-fedora-rpms.zip
TARGET_DOWNLOAD_DIRECTORY=/tmp/hyprland-fedora-rpms

# Download latest zip version
URL_LATEST_ZIP=$(curl -s https://api.github.com/repos/karboggy/hyprland-fedora/releases/latest \
    | jq -r '.assets[] | select(.name | endswith("_hyprland-fedora-rpms.zip")) | .browser_download_url')

if [[ -z "$URL_LATEST_ZIP" || "$URL_LATEST_ZIP" == "null" ]]; then
  echo "ERROR: zip file not found in latest release!" >&2
  exit 1
fi

# Cleanup
rm -rf "$TARGET_DOWNLOAD_DIRECTORY" "$TARGET_DOWNLOAD_ZIP"

# Download latest zip file
wget -O "$TARGET_DOWNLOAD_ZIP" "$URL_LATEST_ZIP"

# Unzip it
unzip -o -d  $TARGET_DOWNLOAD_DIRECTORY $TARGET_DOWNLOAD_ZIP

# Install/Update RPM packages
sudo dnf install "$TARGET_DOWNLOAD_DIRECTORY"/*.rpm
