#!/usr/bin/env bash
set -e
set -x

# If you are making a g++ symlink:
mkdir -p ./mybin
ln -s "$(command -v $CXX)" ./mybin/g++
export PATH="$(pwd)/mybin:$PATH"

# Now build and install
$PYTHON -m pip install . --no-deps --ignore-installed -vv
