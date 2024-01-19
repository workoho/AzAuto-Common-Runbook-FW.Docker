#!/bin/bash

# Define variables
TARGETPLATFORM=$3
IMAGE_NAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
TAG_NAME=$1

# Build the Docker image
if [[ "$TARGETPLATFORM" == linux/* ]]; then
    docker build --file Dockerfile.linux --build-arg TARGETPLATFORM=$TARGETPLATFORM -t $IMAGE_NAME:$TAG_NAME .
    if [ $? -ne 0 ]; then
        exit 1
    fi
    exit 0
fi
if [[ "$TARGETPLATFORM" == windows/* ]]; then
    docker build --file Dockerfile.windows --build-arg TARGETPLATFORM=$TARGETPLATFORM -t $IMAGE_NAME:$TAG_NAME .
    if [ $? -ne 0 ]; then
        exit 1
    fi
    exit 0
fi

echo "Unsupported target platform: $TARGETPLATFORM"

exit 1
