#!/bin/bash
set -ex

# Eigen 3.4.0 is vendored as a second source entry (eigen-src/) so the build
# needs no network: FetchContent picks it up via FETCHCONTENT_SOURCE_DIR_*.
# ccache refuses to cache TUs compiled against a PCH unless these sloppiness
# flags are set (documented requirement for -include pch headers).
export CCACHE_SLOPPINESS="pch_defines,time_macros"

# On macOS ccache canonicalizes -isysroot by asking xcodebuild for the SDK
# path (`xcodebuild -version -sdk <name> Path`). Inside the conda-build
# environment the active developer dir doesn't contain the SDK, so the lookup
# prints "UNKNOWN" and ccache aborts with "not an absolute path". Point
# xcodebuild at the Xcode that actually holds CONDA_BUILD_SYSROOT:
# .../Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/<sdk>.sdk
if [[ "${target_platform}" == osx-* && "${CONDA_BUILD_SYSROOT:-}" == */Platforms/* ]]; then
    export DEVELOPER_DIR="${CONDA_BUILD_SYSROOT%%/Platforms/*}"
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHYPHY3_BUILD_TESTS=OFF \
    -DFETCHCONTENT_SOURCE_DIR_EIGEN3="${SRC_DIR}/eigen-src" \
    -DPython3_EXECUTABLE="${PYTHON}"

# Several TUs (emitters, Eigen-heavy analyses, the PCH) peak at ~3G each.
# Bioconda's Linux CI hosts report only ~8.5G free and the build container has
# no memory cap, so -j4 (~11.4G peak, measured on Kaggle) gets OOM-killed and
# the job just "stops responding". Keep -j2 to stay under ~6G; the compile is
# only ~10min/variant so this costs little.
JOBS=$(( CPU_COUNT < 2 ? CPU_COUNT : 2 ))
ninja -C build -j"${JOBS}"

# Upstream install() puts all CLI binaries in bin/ and the _hyphy3 module
# in lib/ (SKBUILD branch puts it at the wheel root instead; not our case).
ninja -C build install

# Python module + wrapper -> site-packages.
install -d "${SP_DIR}"
mv "${PREFIX}"/lib/_hyphy3*.so "${SP_DIR}/"
cp -r python/hyphy3 "${SP_DIR}/"
# Do not ship build artifacts that landed next to the module.
rm -rf "${SP_DIR}/hyphy3/__pycache__" "${SP_DIR}/hyphy3/tests"
