#!/bin/bash

# Check if the script is running on an Apple Silicon Mac
if [[ "$(uname -m)" != "arm64" ]]; then
    echo "This script should only be run on an Apple Silicon Mac."
    exit 1
fi

# Save the current directory and change to the parent directory of the script
pushd "$(dirname "$0")/.." > /dev/null

# Ensure we return to the original directory on exit
trap "popd > /dev/null" EXIT

# Build the Docker image
docker build --file ./macos/arm64/Dockerfile -t azauto-common-runbook-fw:mariner-2.0-arm64 ./macos/arm64
if [ $? -ne 0 ]; then
    exit 1
fi

docker tag azauto-common-runbook-fw:mariner-2.0-arm64 ghcr.io/workoho/azauto-common-runbook-fw:mariner-2.0-arm64

docker login ghcr.io
if [ $? -ne 0 ]; then
    exit 1
fi

docker push ghcr.io/workoho/azauto-common-runbook-fw:mariner-2.0-arm64

docker manifest create --amend ghcr.io/workoho/azauto-common-runbook-fw:latest \
    ghcr.io/workoho/azauto-common-runbook-fw:mariner-2.0-amd64 \
    ghcr.io/workoho/azauto-common-runbook-fw:mariner-2.0-arm64
docker manifest push --purge ghcr.io/workoho/azauto-common-runbook-fw:latest

exit 0
