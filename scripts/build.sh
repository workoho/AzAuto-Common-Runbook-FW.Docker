#!/bin/bash

# Define variables
IMAGE_NAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
TAG_NAME=$1

# Build the Docker image
docker build -t $IMAGE_NAME:$TAG_NAME .
