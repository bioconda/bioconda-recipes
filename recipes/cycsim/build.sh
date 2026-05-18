#!/bin/bash -exuo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"
mkdir -p "${CARGO_HOME}"

export CMAKE_POLICY_VERSION_MINIMUM=3.5
export CFLAGS="${CFLAGS:-} -O3"
export CXXFLAGS="${CXXFLAGS:-} -O3"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export OPENSSL_DIR="${PREFIX}"
export OPENSSL_NO_VENDOR=1


if [ "$(uname)" == "Darwin" ]; then
    SHLIB_EXT="dylib"
    # macOS uses DYLD_FALLBACK_LIBRARY_PATH
    LIB_VAR="DYLD_FALLBACK_LIBRARY_PATH"
else
    SHLIB_EXT="so"
    # Linux uses LD_LIBRARY_PATH
    LIB_VAR="LD_LIBRARY_PATH"
fi

CLANG_ROOT="${BUILD_PREFIX:-$PREFIX}"
export LIBCLANG_PATH="${CLANG_ROOT}/lib"
export "${LIB_VAR}"="${CLANG_ROOT}/lib:${!LIB_VAR:-}"
TARGET_LIB="${LIBCLANG_PATH}/libclang.${SHLIB_EXT}"

if [ ! -f "${TARGET_LIB}" ]; then
    FOUND_LIB=$(find "${LIBCLANG_PATH}" -name "libclang*.${SHLIB_EXT}*" ! -name "*cpp*" | head -n 1)
    
    if [ -n "$FOUND_LIB" ]; then
        ln -sf "$FOUND_LIB" "${TARGET_LIB}"
    else
        ls -F "${LIBCLANG_PATH}" || true
        exit 1
    fi
fi

export BINDGEN_EXTRA_CLANG_ARGS="-I${PREFIX}/include"
mkdir -p build_edlib_tmp
pushd build_edlib_tmp
cmake ../edlib_cpp_manual \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}"

make -j"${CPU_COUNT:-1}"
make install
popd

export RUSTFLAGS="-L native=${PREFIX}/lib"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --root "${PREFIX}" --path . --verbose
rm -rf target build_edlib_tmp edlib_cpp_manual "${CARGO_HOME}"