#!/usr/bin/env bash
set -euo pipefail

# Create out directory on the host
rm -rf ./out && mkdir -p ./out

# Build Fedora with all required packages to compile all hyprland
docker build -t hyprland-fedora43:latest .

# Clone, compile and generate all RPMS 
docker run \
    --rm \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    -v "$(pwd)/out:/out" hyprland-fedora43
