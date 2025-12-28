#!/usr/bin/env bash

# Create out directory on the host
sudo rm -rf ./out && mkdir -p ./out

# Build Fedora with all required packages to compile all hyprland
docker build -t hyprland-fedora43:latest .

# Clone, compile and generate all RPMS 
docker run --rm -v "$(pwd)/out:/out" hyprland-fedora43
