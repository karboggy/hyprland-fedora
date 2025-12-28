#!/usr/bin/env bash
set -euo pipefail

echo "Starting RPM build inside container"

# clean output dir
mkdir -p /out
rm -rf /out/*

/root/build.sh
/root/craft-rpm-files.sh

echo "RPM build complete!"
