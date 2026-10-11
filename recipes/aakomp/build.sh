#!/bin/bash
set -eu -o pipefail

# Export required paths for Boost and other libraries
export BOOST_ROOT="${PREFIX}"

# macOS std::filesystem compatibility adjustments
if [[ "${target_platform}" == osx-* ]]; then
    export MACOSX_DEPLOYMENT_TARGET="10.15"
    export CXXFLAGS="${CXXFLAGS:-} -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=10.15"
fi

# Configure and build with Meson + Ninja
mkdir -p build
meson setup build --prefix="${PREFIX}"
cd build
ninja install

