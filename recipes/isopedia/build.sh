#!/bin/bash
set -ex

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

# For bindgen (hts-sys needs libclang to generate FFI bindings)
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# Fix: bindgen/clang cannot find stddef.h
CLANG_RESOURCE_DIR=$(clang -print-resource-dir 2>/dev/null || true)
if [ -z "${CLANG_RESOURCE_DIR}" ] || [ ! -d "${CLANG_RESOURCE_DIR}/include" ]; then
    CLANG_RESOURCE_DIR=$(find "${BUILD_PREFIX}" -path "*/lib/clang/*/include/stddef.h" -print -quit 2>/dev/null | xargs dirname | xargs dirname || true)
fi
if [ -n "${CLANG_RESOURCE_DIR}" ] && [ -d "${CLANG_RESOURCE_DIR}/include" ]; then
    export BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS:-} -I${CLANG_RESOURCE_DIR}/include"
fi
if [ -d "${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include" ]; then
    export BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS:-} -I${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include"
fi

# rust-htslib static build needs these to find system libs
export OPENSSL_DIR="${PREFIX}"
export OPENSSL_LIB_DIR="${PREFIX}/lib"
export OPENSSL_INCLUDE_DIR="${PREFIX}/include"

# For pkg-config to find host deps
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

# htslib vendored build flags
export HTS_SYS_CONFIGURE_ARGS="--disable-plugins --disable-s3"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Build release
cargo build --release

# Find the actual output directory (may be target/release or target/<triple>/release)
RELEASE_DIR="target/release"
if [ ! -f "${RELEASE_DIR}/isopedia" ]; then
    RELEASE_DIR=$(find target -path "*/release/isopedia" -not -path "*/build/*" -print -quit | xargs dirname || true)
fi
echo "Release directory: ${RELEASE_DIR}"

# Install binaries
mkdir -p "${PREFIX}/bin"
install -m 755 "${RELEASE_DIR}/isopedia" "${PREFIX}/bin/"
install -m 755 "${RELEASE_DIR}/isopedia-tools" "${PREFIX}/bin/"
install -m 755 script/isopedia-splice-viz.py "${PREFIX}/bin/"

# Install data files
mkdir -p "${PREFIX}/share/isopedia"
install -m 644 script/isopedia-splice-viz-temp.html "${PREFIX}/share/isopedia/"

# Third-party licenses (bioconda requirement for Rust crates)
cargo-bundle-licenses --format yaml --output THIRDPARTY_LICENSES