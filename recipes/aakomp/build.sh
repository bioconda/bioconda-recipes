#!/bin/bash
set -eu -o pipefail

# Export required paths for Boost and other libraries
export BOOST_ROOT="${PREFIX}"

# Configure and build with Meson + Ninja
mkdir -p build
meson setup build --prefix="${PREFIX}"
cd build
ninja install

