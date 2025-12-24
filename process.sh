#!/usr/bin/env bash

# create out directory on the host
sudo rm -rf ./out && mkdir -p ./out

docker build -t hyprland-fedora43:latest .

# bring back binaries from container
docker run \
    --rm \
    -v "$(pwd)/out:/host_out" \
    hyprland-fedora43:latest \
    cp -r /out/. /host_out/