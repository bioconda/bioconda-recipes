#!/bin/bash

# Build script for conda on Unix-like systems (Linux, macOS)

set -ex

# Configure and build with CMake via scikit-build-core
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Verify the installation
${PYTHON} -c "import zna; print(f'ZNA version: {zna.__version__ if hasattr(zna, \"__version__\") else \"0.1.0\"}')"
${PYTHON} -c "from zna.core import is_accelerated; print(f'C++ acceleration: {is_accelerated()}')"
