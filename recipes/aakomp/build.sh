#!/bin/bash
set -eu -o pipefail

export BOOST_ROOT="${PREFIX}"

if [[ "${target_platform}" == osx-* ]]; then
    export MACOSX_DEPLOYMENT_TARGET="11.3"
    export CXXFLAGS="${CXXFLAGS:-} -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=11.3"
    export LDFLAGS="${LDFLAGS:-} -mmacosx-version-min=11.3"
fi

mkdir -p build
meson setup build \
    --prefix="${PREFIX}" \
    --libdir="lib" \
    -Dwerror=false \
    -Dwarning_level=1

ninja -C build install
