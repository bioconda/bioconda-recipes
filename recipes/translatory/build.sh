#!/bin/bash

# Create the binary directory in the Conda environment
mkdir -p ${PREFIX}/bin

# Copy the Python script, rename it without the extension, and make it executable
cp translatory.py ${PREFIX}/bin/translatory
chmod +x ${PREFIX}/bin/translatory
