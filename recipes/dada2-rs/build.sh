#!/bin/bash
set -xeuo pipefail

# conda-build does not unpack .crate files. Strip the top directory so LICENSE
# and THIRDPARTY.yml sit at the source root, where license_file looks.
tar -xzf "${PKG_NAME}-${PKG_VERSION}.crate" --strip-components=1
rm -f "${PKG_NAME}-${PKG_VERSION}.crate"

# Upstream HPCBio/dada2-rs#329: without it, Cargo's new build-dir layout tags
# the version '+build'. Applied here, not via source/patches, because patches
# run before this script unpacks the crate. Drop at the next release.
patch -p1 < "${RECIPE_DIR}/build-tags-new-build-dir.patch"

# Bundle the licenses of every vendored Rust dependency.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Portable build: no target-cpu flags, so the binary runs on any CPU of the
# platform. The GitHub release binaries are tuned (x86-64-v3) and faster.
export CARGO_PROFILE_RELEASE_STRIP=true
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
