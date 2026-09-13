#!/bin/bash -e

set -x

# HOME is not passed to conda-build, so cargo's default "${HOME}/.cargo"
# resolves to a non-absolute "UNKNOWN" path and cargo-bundle-licenses panics
# on macOS. Point CARGO_HOME at an absolute path instead.
export CARGO_HOME="${BUILD_PREFIX}/.cargo"

# rustc's default linker on macOS is the system `cc`, which resolves its
# toolchain through xcodebuild. bioconda's CI installs the MacOSX11.3 SDK
# under Xcode 15.4, which refuses SDKs below 13.0 ("cannot be located"),
# so linking via `cc` fails with exit status 72. Use the conda clang as
# the Rust linker instead; it does not consult xcodebuild.
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="${CC}"
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER="${CC}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/oxo-flow-cli

set +x
