#!/bin/bash
set -ex

# Eigen 3.4.0 is vendored as a second source entry (eigen-src/) so the build
# needs no network: FetchContent picks it up via FETCHCONTENT_SOURCE_DIR_*.
cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHYPHY3_BUILD_TESTS=OFF \
    -DFETCHCONTENT_SOURCE_DIR_EIGEN3="${SRC_DIR}/eigen-src" \
    -DPython3_EXECUTABLE="${PYTHON}"

ninja -C build -j"${CPU_COUNT}"

# Upstream install() puts all CLI binaries in bin/ and the _hyphy3 module
# in lib/ (SKBUILD branch puts it at the wheel root instead; not our case).
ninja -C build install

# Python module + wrapper -> site-packages.
install -d "${SP_DIR}"
mv "${PREFIX}"/lib/_hyphy3*.so "${SP_DIR}/"
cp -r python/hyphy3 "${SP_DIR}/"
# Do not ship build artifacts that landed next to the module.
rm -rf "${SP_DIR}/hyphy3/__pycache__" "${SP_DIR}/hyphy3/tests"
