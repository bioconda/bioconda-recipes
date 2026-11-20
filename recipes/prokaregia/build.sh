#!/bin/bash

# Build script for ProkaRegia conda package
# Only copies files needed to run the pipeline

set -e

# Create installation directory
mkdir -p $PREFIX/share/prokaregia

# Copy essential pipeline files
cp ${SRC_DIR}/Snakefile $PREFIX/share/prokaregia/
cp ${SRC_DIR}/config.yaml $PREFIX/share/prokaregia/
cp ${SRC_DIR}/environment.yml $PREFIX/share/prokaregia/
cp ${SRC_DIR}/run_prokaregia.sh $PREFIX/share/prokaregia/

# Copy directories needed for the pipeline
cp -r ${SRC_DIR}/envs $PREFIX/share/prokaregia/
cp -r ${SRC_DIR}/scripts $PREFIX/share/prokaregia/

# Make wrapper script executable
chmod +x $PREFIX/share/prokaregia/run_prokaregia.sh

# Create bin directory and symlink
mkdir -p $PREFIX/bin
ln -s $PREFIX/share/prokaregia/run_prokaregia.sh $PREFIX/bin/prokaregia

echo "ProkaRegia installed to $PREFIX/share/prokaregia/"
echo "Command available as: prokaregia"
