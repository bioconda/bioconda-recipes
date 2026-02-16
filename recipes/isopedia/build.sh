#!/bin/bash
set -ex

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

# For bindgen (hts-sys needs libclang to generate FFI bindings)
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

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

# Install binaries
mkdir -p "${PREFIX}/bin"
install -m 755 target/release/isopedia "${PREFIX}/bin/"
install -m 755 target/release/isopedia-tools "${PREFIX}/bin/"
install -m 755 script/isopedia-splice-viz.py "${PREFIX}/bin/"

# Install data files
mkdir -p "${PREFIX}/share/isopedia"
install -m 644 script/isopedia-splice-viz-temp.html "${PREFIX}/share/isopedia/"

# Third-party licenses (bioconda requirement for Rust crates)
cargo-bundle-licenses --format yaml --output THIRDPARTY_LICENSES