#!/usr/bin/env bash
set -e  # Exit immediately if a command exits with a non-zero status

# Create a directory for the symlink
mkdir -p "$(pwd)/mybin"

# Create a symlink named "g++" pointing to the conda-provided C++ compiler.
# The {{ compiler('cxx') }} macro will be rendered by conda-build.
ln -s "$(which {{ compiler('cxx') }})" "$(pwd)/mybin/g++"

# Prepend this directory to PATH so that when the Makefile calls "g++" it finds our symlink.
export PATH="$(pwd)/mybin:$PATH"

# Build and install the package using pip.
{{ PYTHON }} -m pip install . --no-deps --ignore-installed -vv
