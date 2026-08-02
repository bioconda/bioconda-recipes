#!/bin/bash
set -e
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

sed -i.bak "s|-O3|-O3 -D_LIBCPP_DISABLE_AVAILABILITY|" Makefile
rm -f *.bak

# If you are making a g++ symlink:
mkdir -p ./mybin
ln -s "$(command -v $CXX)" ./mybin/g++
export PATH="$(pwd)/mybin:$PATH"

# Now build and install
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
