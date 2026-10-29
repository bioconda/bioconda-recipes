#!/usr/bin/env bash
set -eux

cd "${SRC_DIR}/panmap"

# minimap2 builds via its own Makefile and does not inherit CMake's include/lib
# dirs; upstream keys that fallback on CONDA_PREFIX, which conda-build does not
# set (it uses PREFIX). Expose the conda prefix to every sub-compiler here.
export CPATH="${PREFIX}/include${CPATH:+:${CPATH}}"
export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"

# Restrict find_package/find_library/find_path to the host prefix so panmap links
# the HOST libraries (which match their run_exports), not BUILD_PREFIX copies pulled
# in by build-time tools — e.g. protobuf drags a newer abseil into BUILD_PREFIX, and
# an unrestricted find_package(absl) would link that, leaving the runtime looking for
# an absl .so the run env doesn't have. find_program stays unrestricted, so the
# capnp/protoc generators still come from BUILD_PREFIX.
CONFIG_ARGS="-DCMAKE_FIND_ROOT_PATH=${PREFIX}"
CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY"
CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY"
if [[ $(uname -s) == "Darwin" ]]; then
    # Also keep Homebrew/system frameworks out and add the SDK sysroot.
    SYSROOT="${CONDA_BUILD_SYSROOT:-$(xcrun --show-sdk-path)}"
    CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
    CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH=${PREFIX};${SYSROOT}"
fi

# Drive panmap's own CMakeLists (USE_SYSTEM_LIBS builds against the conda libs;
# PANMAN_SOURCE_DIR supplies the panman source from the 2nd tarball, no network).
# Code generators come from the HOST prefix (native arch on bioconda's per-platform
# builders), so no build-side libprotobuf/capnproto — which would pull a second abseil.
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DUSE_SYSTEM_LIBS=ON \
    -DPANMAN_SOURCE_DIR="${SRC_DIR}/panman" \
    -DCAPNP_EXECUTABLE="${PREFIX}/bin/capnp" \
    -DCAPNPC_CXX_EXECUTABLE="${PREFIX}/bin/capnpc-c++" \
    -DProtobuf_PROTOC_EXECUTABLE="${PREFIX}/bin/protoc" \
    -DOPTION_BUILD_TESTS=OFF \
    -DOPTION_BUILD_SIMULATE=OFF \
    -Wno-dev --no-warn-unused-cli \
    ${CONFIG_ARGS}

cmake --build build -j "${CPU_COUNT}"
# panmanUtils is EXCLUDE_FROM_ALL upstream (panmap links libpanman.a directly, and
# the CLI recompiles the heavy protobuf/capnp TUs), so build it on demand.
cmake --build build --target panmanUtils -j "${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 build/bin/panmap "${PREFIX}/bin/"
# Ship panmanUtils built against the same capnproto as panmap. The bioconda
# `panman` package pins an older capnproto and cannot be a run dep / coexist.
install -v -m 0755 build/panman-build/panmanUtils "${PREFIX}/bin/"
