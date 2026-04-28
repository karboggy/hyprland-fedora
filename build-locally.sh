#!/usr/bin/env bash
set -euo pipefail

BUILD_FLAVOR="${1:-}"
DOCKER_IMAGE="hyprland-fedora43"
VERSION_MANIFEST=""

case "$BUILD_FLAVOR" in
    "")
        echo "ERROR: missing build flavor" >&2
        echo "Usage: $0 [nightly|stable]" >&2
        exit 1
        ;;
    nightly)
        ;;
    stable)
        DOCKER_IMAGE="hyprland-fedora43-stable"
        VERSION_MANIFEST="/root/versions/stable.env"
        ;;
    -h|--help)
        echo "Usage: $0 [nightly|stable]"
        exit 0
        ;;
    *)
        echo "ERROR: unknown build flavor: $BUILD_FLAVOR" >&2
        echo "Usage: $0 [nightly|stable]" >&2
        exit 1
        ;;
esac

# Create out directory on the host
rm -rf ./out && mkdir -p ./out

# Build Fedora with all required packages to compile all hyprland
docker build -t "$DOCKER_IMAGE:latest" .

docker_args=(
    --rm
    -e HOST_UID="$(id -u)"
    -e HOST_GID="$(id -g)"
)

if [[ -n "$VERSION_MANIFEST" ]]; then
    docker_args+=(-e VERSION_MANIFEST="$VERSION_MANIFEST")
fi

# Clone, compile and generate all RPMS
docker run \
    "${docker_args[@]}" \
    -v "$(pwd)/out:/out" \
    "$DOCKER_IMAGE:latest"
