#!/usr/bin/env bash
set -euo pipefail

BUILD_FLAVOR="${1:-}"
FEDORA_VERSION="${2:-}"

usage() {
    echo "Usage: $0 [nightly|stable] [43|44]"
}

case "$BUILD_FLAVOR" in
  nightly)
    ;;
  stable)
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  "")
    echo "ERROR: missing build flavor" >&2
    usage >&2
    exit 1
    ;;
  *)
    echo "ERROR: unknown build flavor: $BUILD_FLAVOR" >&2
    usage >&2
    exit 1
    ;;
esac

case "$FEDORA_VERSION" in
  43|44)
    ;;
  "")
    echo "ERROR: missing Fedora version" >&2
    usage >&2
    exit 1
    ;;
  *)
    echo "ERROR: unsupported Fedora version: $FEDORA_VERSION" >&2
    usage >&2
    exit 1
    ;;
esac

case "$BUILD_FLAVOR" in
  nightly)
    ASSET_SUFFIX="_hyprland-fedora${FEDORA_VERSION}-nightly-rpms.zip"
    RELEASE_TAG_SUFFIX="_fedora${FEDORA_VERSION}_nightly"
    ;;
  stable)
    ASSET_SUFFIX="_hyprland-fedora${FEDORA_VERSION}-stable-rpms.zip"
    RELEASE_TAG_SUFFIX="_fedora${FEDORA_VERSION}_stable"
    ;;
esac

for cmd in curl jq wget unzip sudo dnf; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $cmd" >&2
    exit 1
  fi
done

# Configuration
TARGET_DOWNLOAD_ZIP="/tmp/hyprland-fedora${FEDORA_VERSION}-${BUILD_FLAVOR}-rpms.zip"
TARGET_DOWNLOAD_DIRECTORY="/tmp/hyprland-fedora${FEDORA_VERSION}-${BUILD_FLAVOR}-rpms"

# Download latest zip version for the selected flavor
URL_LATEST_ZIP=$(curl -fsSL 'https://api.github.com/repos/karboggy/hyprland-fedora/releases?per_page=100' \
    | jq -r --arg suffix "$ASSET_SUFFIX" --arg tag_suffix "$RELEASE_TAG_SUFFIX" \
        '[.[] | select(.tag_name | contains($tag_suffix + "_")) | .assets[] | select(.name | endswith($suffix)) | .browser_download_url][0] // empty')

if [[ -z "$URL_LATEST_ZIP" || "$URL_LATEST_ZIP" == "null" ]]; then
  echo "ERROR: ${BUILD_FLAVOR} zip file not found in releases!" >&2
  exit 1
fi

# Cleanup
rm -rf "$TARGET_DOWNLOAD_DIRECTORY" "$TARGET_DOWNLOAD_ZIP"

# Download latest zip file
wget -O "$TARGET_DOWNLOAD_ZIP" "$URL_LATEST_ZIP"

# Unzip it
unzip -o -d "$TARGET_DOWNLOAD_DIRECTORY" "$TARGET_DOWNLOAD_ZIP"

# Install/Update RPM packages
sudo dnf install "$TARGET_DOWNLOAD_DIRECTORY"/*.rpm
