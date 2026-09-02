#!/bin/bash

set -euxo pipefail

# rust-htslib 1.0.1 forces the `bindgen` feature on hts-sys, which runs bindgen
# at build time; point clang-sys at the conda libclang so it is found.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# hts-sys builds a bundled htslib from source and generates its FFI bindings
# with bindgen; point the C preprocessor/linker and bindgen's clang at the conda
# prefix so the bundled build finds the host libs (zlib, bzip2, xz, openssl,
# libcurl) and headers.
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
# flate2's zlib-ng backend (libz-ng-sys) compiles vendored C; modern clang makes
# implicit function declarations an error, so relax that for the vendored build.
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations -Wno-implicit-function-declaration"
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

# On macOS, undefined symbols (openssl/libcurl) are resolved at load time.
if [[ "$(uname)" == "Darwin" ]]; then
  export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# Bundle the verbatim license text of every Cargo dependency (bioconda
# requirement for Rust recipes). Run before the build so it resolves the
# workspace crate graph.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# unum is a Cargo workspace; the binary lives in crates/unum. Build against the
# committed Cargo.lock (--locked) so the pinned crate versions are used.
export RUST_BACKTRACE=1
cargo install --no-track --locked --verbose --path crates/unum --root "${PREFIX}"
