#!/bin/bash

# Script to test metagraph build in Docker with SSH support

set -e

echo "Building Docker image for metagraph testing..."

# Build the Docker image
docker build -f test-metagraph.Dockerfile -t metagraph-test .

echo "Docker image built successfully!"

# Check if SSH keys exist
if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Warning: No SSH keys found. The build will fall back to local compilation."
fi

echo "Starting Docker container with SSH support..."

# Run the container with SSH key mounting
docker run --rm -it \
    -v ~/.ssh:/root/.ssh:ro \
    -v ~/.ssh/config:/root/.ssh/config:ro \
    -v ~/.ssh/known_hosts:/root/.ssh/known_hosts:ro \
    metagraph-test

echo "Docker container execution completed!"



