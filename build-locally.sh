#!/usr/bin/env bash
set -euo pipefail

BUILD_FLAVOR="${1:-}"
FEDORA_VERSION="${2:-}"
DOCKER_IMAGE=""
DOCKERFILE=""
VERSION_MANIFEST=""

usage() {
    echo "Usage: $0 [nightly|stable] [43|44]"
}

case "$BUILD_FLAVOR" in
    "")
        echo "ERROR: missing build flavor" >&2
        usage >&2
        exit 1
        ;;
    nightly)
        ;;
    stable)
        VERSION_MANIFEST="/root/versions/stable.env"
        ;;
    -h|--help)
        usage
        exit 0
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

DOCKER_IMAGE="hyprland-fedora${FEDORA_VERSION}"
DOCKERFILE="docker/fedora${FEDORA_VERSION}/Dockerfile"

if [[ "$BUILD_FLAVOR" == "stable" ]]; then
    DOCKER_IMAGE="${DOCKER_IMAGE}-stable"
fi

# Create out directory on the host
rm -rf ./out && mkdir -p ./out

# Build Fedora with all required packages to compile all hyprland
docker build -f "$DOCKERFILE" -t "$DOCKER_IMAGE:latest" .

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
