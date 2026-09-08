#!/bin/bash

set -euxo pipefail

# minibwa-py is the pyo3/maturin package. It depends on the sibling `minibwa`
# and `minibwa-sys` crates by path (and minibwa-sys vendors the minibwa C), so
# build from within its subdirectory of the workspace source tree.
cd minibwa-py

# minibwa-sys generates its FFI via bindgen, whose clang-sys backend needs to
# locate libclang.so at build time. The conda `clangdev` build dep installs it
# under ${BUILD_PREFIX}/lib; point bindgen at it explicitly.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# minibwa-sys emits `cargo:rustc-link-lib=z`. On Linux rustc's link step does
# not search the host prefix by default (it ignores conda's LDFLAGS), so `-lz`
# fails to resolve; add ${PREFIX}/lib explicitly. On macOS we deliberately do
# NOT add it: `-lz` then resolves against the system libSystem zlib, which
# maturin leaves alone when bundling. Linking conda's libz.1.dylib instead
# breaks maturin's wheel repair ("@rpath/libz.1.dylib could not be located").
# (`pthread`/`m` resolve from the compiler sysroot on both platforms.)
if [[ "$(uname)" != "Darwin" ]]; then
  export RUSTFLAGS="${RUSTFLAGS:-} -L native=${PREFIX}/lib"
fi

# Build the cargo dependency graph from the committed Cargo.lock (`--locked`)
# so the wheel pins the exact crate versions the project tests against, rather
# than re-resolving at build time. maturin forwards this cargo flag, and pip
# (PEP 517) forwards maturin args via MATURIN_PEP517_ARGS.
export MATURIN_PEP517_ARGS="--locked"

${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

# Capture the verbatim license text of every Cargo dependency into a bundle that
# ships with the package (see meta.yaml `license_file`). Run after the build so
# the crate sources are already fetched into CARGO_HOME. NOTE: this covers the
# Rust crate closure ONLY -- libsais is vendored C compiled by minibwa-sys's
# build script, not a crates.io dependency, so it never appears here. Its
# Apache-2.0 text is shipped separately via the recipe's
# LICENSE.libsais-Apache-2.0.txt (also listed in meta.yaml `license_file`).
cargo-bundle-licenses --format yaml --output THIRD-PARTY.yml
