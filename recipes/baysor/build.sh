#!/bin/bash

# Create the bin directory in the conda environment prefix
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/opt/baysor"

# Copy the contents of the zip (already extracted by conda-build into $SRC_DIR)
# The zip contains a 'bin' folder and potentially 'lib' folders.
cp -r ./* "$PREFIX/opt/baysor/"

# Create a symbolic link so 'baysor' is available in the user's PATH
ln -s "$PREFIX/opt/baysor/bin/baysor" "$PREFIX/bin/baysor"

# Ensure the binary is executable
chmod +x "$PREFIX/bin/baysor"