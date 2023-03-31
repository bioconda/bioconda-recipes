#!/bin/bash

# Crate a data/out file to download the output files obtained with Helixer tool && add authority
mkdir -p data/out
chmod o+w data/out

# Build an image from a Dockerfile
docker build -t helixer_v0.3.1 --rm .

# Run image
docker run -ti --name helixer_v0.3.1 helixer_v0.3.1:latest


