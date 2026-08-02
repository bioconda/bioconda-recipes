#!/usr/bin/env bash
set -eux

# Copy the recipe's CMakeLists.txt over the upstream one
cp -f "${RECIPE_DIR}/CMakeLists.txt" "${SRC_DIR}/panmap/CMakeLists.txt"

# Copy panman source into expected location
mkdir -p "${SRC_DIR}/panmap/external/panman"
cp -rf "${SRC_DIR}/panman/"* "${SRC_DIR}/panmap/external/panman/"

# Apply TBB compat patches to panman (oneTBB 2021+ removes task_scheduler_init)
sh "${SRC_DIR}/panmap/cmake/patch_panman.sh" "${SRC_DIR}/panmap/external/panman" true

# Generate version.hpp for panman
cat > "${SRC_DIR}/panmap/external/panman/src/version.hpp" <<'VEOF'
#ifndef VERSION_HPP
#define VERSION_HPP
#define PROJECT_VERSION "1.0.0"
#define PMAT_VERSION "1.0.0"
#endif
VEOF

# Revert bcftools include paths from vendored htslib to system htslib
# (upstream bcftools uses <htslib/...>, panmap's fork rewrote them to relative paths)
find "${SRC_DIR}/panmap/src/3rdparty/bcftools" \( -name "*.c" -o -name "*.h" \) \
    -exec sed -i.bak 's|"../samtools/htslib-1.20/htslib/\([^"]*\)"|<htslib/\1>|g' {} +
find "${SRC_DIR}/panmap/src/3rdparty/bcftools" -name "*.bak" -delete

cd "${SRC_DIR}/panmap"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

# Prevent Homebrew (or any other system packages) from leaking into the build.
# CMAKE_FIND_ROOT_PATH restricts all find_* commands to search only within
# the conda prefix and the SDK sysroot. This is critical on macOS where
# /opt/homebrew headers can cause version mismatches.
if [[ $(uname -s) == "Darwin" ]]; then
    CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
    SYSROOT="${CONDA_BUILD_SYSROOT:-$(xcrun --show-sdk-path)}"
    CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH=${PREFIX};${SYSROOT}"
    CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY"
    CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
    CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY"
else
    CONFIG_ARGS=""
fi

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_C_COMPILER="${CC}" \
    -DPANMAN_SOURCE_DIR="${SRC_DIR}/panmap/external/panman" \
    -DCAPNP_EXECUTABLE="${PREFIX}/bin/capnp" \
    -DCAPNPC_CXX_EXECUTABLE="${PREFIX}/bin/capnpc-c++" \
    -DPROTOBUF_PROTOC_EXECUTABLE="${PREFIX}/bin/protoc" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    ${CONFIG_ARGS}

cmake --build build -j "${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 build/bin/panmap "${PREFIX}/bin/"
install -v -m 0755 build/panman-build/panmanUtils "${PREFIX}/bin/"
