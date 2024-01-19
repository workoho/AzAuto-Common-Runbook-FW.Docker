#!/bin/bash

# Define variables
TARGETPLATFORM=$3
IMAGE_NAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
TAG_NAME=$1

# Build the Docker image
docker build --build-arg TARGETPLATFORM=$TARGETPLATFORM -t $IMAGE_NAME:$TAG_NAME .
