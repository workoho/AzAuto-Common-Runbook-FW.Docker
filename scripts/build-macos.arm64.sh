#!/bin/bash

# Check if the script is running on an Apple Silicon Mac
if [[ "$(uname -m)" != "arm64" ]]; then
    echo "This script should only be run on an Apple Silicon Mac."
    exit 1
fi

# Save the current directory and change to the parent directory of the script
pushd "$(dirname "$0")/.." >/dev/null

# Ensure we return to the original directory and log out of Docker on exit
trap "{ popd > /dev/null; docker logout ghcr.io; gh auth logout; }" EXIT

# Build the Docker image
docker build --file ./macos/arm64/Dockerfile -t azauto-common-runbook-fw:debian-12-arm64 ./macos/arm64
if [ $? -ne 0 ]; then
    exit 1
fi

# Log in to the Docker registry
docker login ghcr.io
if [ $? -ne 0 ]; then
    exit 1
fi

docker tag azauto-common-runbook-fw:debian-12-arm64 ghcr.io/workoho/azauto-common-runbook-fw:debian-12-arm64

docker push ghcr.io/workoho/azauto-common-runbook-fw:debian-12-arm64
if [ $? -eq 0 ]; then
    if command -v gh &>/dev/null; then
        echo "gh found, running workflow ..."
        if gh auth login && gh workflow run docker.yml --ref main; then
            exit 0
        else
            exit 1
        fi
    else
        echo "gh not found, please install GitHub CLI"
        exit 1
    fi
else
    exit 1
fi
