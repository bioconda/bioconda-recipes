#!/bin/bash -e

set -ex

# Use a custom temporary directory as home on macOS.
# (not sure why this is useful, but people use it in bioconda recipes)
if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

# build statically linked binary with Rust
$PYTHON -m pip install . --no-deps --no-build-isolation -vvv
