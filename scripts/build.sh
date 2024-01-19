#!/bin/bash

# Define variables
IMAGE_NAME=$2
TAG_NAME=$1

# Build the Docker image
docker build -t $IMAGE_NAME:$TAG_NAME .
