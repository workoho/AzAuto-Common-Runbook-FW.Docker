#!/bin/bash

# Define variables
TARGETPLATFORM=$4
IMAGE_NAME=$(echo $3 | tr '[:upper:]' '[:lower:]')
TAG_NAME=$2
DOCKERFILE=$1

# Build the Docker image
if [[ "$TARGETPLATFORM" == linux/* ]]; then
    docker build --file $DOCKERFILE --build-arg TARGETPLATFORM=$TARGETPLATFORM -t $IMAGE_NAME:$TAG_NAME .
    if [ $? -ne 0 ]; then
        exit 1
    fi
    exit 0
fi
if [[ "$TARGETPLATFORM" == windows/* ]]; then
    docker build --file $DOCKERFILE --build-arg TARGETPLATFORM=$TARGETPLATFORM -t $IMAGE_NAME:$TAG_NAME .
    if [ $? -ne 0 ]; then
        exit 1
    fi
    exit 0
fi

echo "Unsupported target platform: $TARGETPLATFORM"

exit 1
