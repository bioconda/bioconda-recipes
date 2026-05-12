#!/usr/bin/env bash
set -euxo pipefail

# conda-build strips the tarball top-level directory on macOS but not in
# the Linux docker build environment — handle both cases.
if [ -d "${SRC_DIR}/rastair-${PKG_VERSION}-vendored" ]; then
    cd "${SRC_DIR}/rastair-${PKG_VERSION}-vendored"
fi

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# hts-sys uses bindgen, which needs libclang at build time.
# On Linux (docker), clang/libclang are explicit conda deps in BUILD_PREFIX.
# On macOS, the Xcode SDK provides libclang.
if [ -d "${BUILD_PREFIX}/lib" ]; then
    export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
fi

# Use a local CARGO_HOME to avoid conda-build HOME permission issues.
export CARGO_HOME="${SRC_DIR}/.cargo-home"
mkdir -p "${CARGO_HOME}"

# CI builders can have tight memory limits; cap parallel rustc jobs to avoid OOM.
: "${CARGO_BUILD_JOBS:=1}"
: "${CARGO_PROFILE_RELEASE_CODEGEN_UNITS:=1}"

# Build and install the Rust binary (--frozen for offline/vendored builds).
cargo install --frozen --no-track --path . --root "${PREFIX}" --bin rastair --jobs "${CARGO_BUILD_JOBS}"

# Generate third-party licence bundle required by bioconda.
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

# Copy licence to SRC_DIR so conda-build can find it for packaging.
# When conda-build strips the top-level directory (macOS), we're already in
# SRC_DIR and the file is already there — skip to avoid cp failing on self-copy.
if [ "$(realpath LICENSE.txt)" != "$(realpath "${SRC_DIR}/LICENSE.txt")" ]; then
    cp LICENSE.txt "${SRC_DIR}/LICENSE.txt"
fi

# Install auxiliary scripts used by `rastair mbias`.
mkdir -p "${PREFIX}/share/rastair/scripts"
cp -v scripts/mbias.R scripts/QC_report.Rmd "${PREFIX}/share/rastair/scripts/"
chmod +x "${PREFIX}/share/rastair/scripts/mbias.R"

# Generate and install shell completion scripts.
mkdir -p "${PREFIX}/share/bash-completion/completions"
"${PREFIX}/bin/rastair" internal shell-completions bash > "${PREFIX}/share/bash-completion/completions/rastair"

mkdir -p "${PREFIX}/share/zsh/site-functions"
"${PREFIX}/bin/rastair" internal shell-completions zsh > "${PREFIX}/share/zsh/site-functions/_rastair"

mkdir -p "${PREFIX}/share/fish/vendor_completions.d"
"${PREFIX}/bin/rastair" internal shell-completions fish > "${PREFIX}/share/fish/vendor_completions.d/rastair.fish"
