#!/bin/bash

# Check if gcc is available. As gcc is hardcoded in haddock3 setup.py, it's unavailableon Bioconda tests.
if ! command -v gcc >/dev/null 2>&1; then
    echo "gcc not found, skipping Haddock3 installation, please do 'pip install haddock3' manually."
    exit 0
fi

# Proceed with pip installation if gcc is available
echo "gcc found, proceeding with Haddock3 installation..."
pip install haddock3 --no-deps --ignore-installed --no-cache-dir -vvv