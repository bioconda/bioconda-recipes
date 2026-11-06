#!/bin/bash
set -ex

# -----------------------------------------------------------------------------
# macOS deployment target and warning normalization
# -----------------------------------------------------------------------------
MESON_EXTRA_FLAGS=()

if [[ "${target_platform}" == osx-* ]]; then
    # conda-forge libc++ is built for macOS 11.0+; align deployment target
    export MACOSX_DEPLOYMENT_TARGET="11.3"
    TARGET_VER="11.3"

    # 1. Clean out conflicting -mmacosx-version-min and -Wl,-fatal_warnings from env vars
    export CFLAGS="$(echo "${CFLAGS:-}" | sed -E 's/-mmacosx-version-min=[0-9.]+//g')"
    export CXXFLAGS="$(echo "${CXXFLAGS:-}" | sed -E 's/-mmacosx-version-min=[0-9.]+//g')"
    export LDFLAGS="$(echo "${LDFLAGS:-}" | sed -E 's/-mmacosx-version-min=[0-9.]+//g' | sed 's/-Wl,-fatal_warnings//g')"

    # 2. Re-apply uniform target version
    export CFLAGS="${CFLAGS} -mmacosx-version-min=${TARGET_VER}"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${TARGET_VER}"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${TARGET_VER}"

    # 3. Force Meson to pass link flags without fatal warnings
    MESON_EXTRA_FLAGS+=(
        "-Dc_args=-mmacosx-version-min=${TARGET_VER}"
        "-Dcpp_args=-mmacosx-version-min=${TARGET_VER}"
        "-Dc_link_args=-mmacosx-version-min=${TARGET_VER} -Wl,-no_warn_duplicate_libraries"
        "-Dcpp_link_args=-mmacosx-version-min=${TARGET_VER} -Wl,-no_warn_duplicate_libraries"
    )
fi

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include -Wno-deprecated-declarations"

# -----------------------------------------------------------------------------
# Patch bundled subprojects for CMake compatibility
# -----------------------------------------------------------------------------
sed -i.bak 's|VERSION 3.1.0|VERSION 3.5|' subprojects/cpptoml/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.11|VERSION 3.5|' subprojects/sdsl-lite/CMakeLists.txt
rm -rf subprojects/cpptoml/*.bak
rm -rf subprojects/sdsl-lite/*.bak

sed -i.bak '/find_package(LIBCXX/d' subprojects/cpptoml/CMakeLists.txt
sed -i.bak '/set_libcxx_required_flags/d' subprojects/cpptoml/CMakeLists.txt
rm -rf subprojects/cpptoml/*.bak

# -----------------------------------------------------------------------------
# Build and install
# -----------------------------------------------------------------------------
meson setup --buildtype release \
    --prefix "${PREFIX}" \
    --strip \
    -Db_coverage=false \
    "${MESON_EXTRA_FLAGS[@]}" \
    build/

cd build

ninja install -v -j"${CPU_COUNT}"

# Python wrappers
${PYTHON} -m pip install "${PREFIX}/lib/btllib/python" --no-deps --no-build-isolation --no-cache-dir -vvv
