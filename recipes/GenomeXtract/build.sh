#!/bin/bash

# Exit on error
set -e

# Install Python package
$PYTHON -m pip install . --no-deps --ignore-installed
