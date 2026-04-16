#!/bin/bash

# Configuration
IMAGE="hashicorp/terraform:latest"
DOCKER_SOCK="/var/run/docker.sock"
WORKDIR="/app"

# Check if docker socket exists
if [ ! -S "$DOCKER_SOCK" ]; then
    echo "Error: Docker socket not found at $DOCKER_SOCK"
    echo "Make sure Docker is running."
    exit 1
fi

# Run Terraform in Docker
docker run --rm -it \
  -v "$DOCKER_SOCK":"$DOCKER_SOCK" \
  -v "$(pwd)":"$WORKDIR" \
  -w "$WORKDIR" \
  --user "$(id -u):$(id -g)" \
  "$IMAGE" "$@"
