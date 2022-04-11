#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

# Use a custom temporary directory as home on macOS.
# (not sure why this is useful, but people use it in bioconda recipes)
if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

# Build the package using maturin - should produce *.whl files.
maturin build --interpreter python --release

# Install *.whl files using pip
$PYTHON -m pip install target/wheels/*.whl --no-deps --ignore-installed -vv