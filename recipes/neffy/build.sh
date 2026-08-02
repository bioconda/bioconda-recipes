#!/usr/bin/env bash
set -e
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

# If you are making a g++ symlink:
mkdir -p ./mybin
ln -s "$(command -v $CXX)" ./mybin/g++
export PATH="$(pwd)/mybin:$PATH"

# Now build and install
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vv
