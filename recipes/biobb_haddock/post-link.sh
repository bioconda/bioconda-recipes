#!/bin/bash

# Check if gcc is available
if ! command -v gcc >/dev/null 2>&1; then
    echo "gcc not found, skipping Haddock3 installation, please do 'pip install haddock3' manually."
    exit 0
fi

# Proceed with pip installation if gcc is available
echo "gcc found, proceeding with Haddock3 installation..."
pip install haddock3 --no-deps
