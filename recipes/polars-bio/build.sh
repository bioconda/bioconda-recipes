#!/bin/bash
set -euxo pipefail

# The source tree pins an exact toolchain for local development. The conda build
# supplies its own rustc and has no rustup to honour the pin with, so drop it.
rm -f rust-toolchain.toml

# Upstream CI builds wheels with `-Ctarget-cpu=skylake` / `apple-m1` and
# `-Dwarnings`. Neither is appropriate for a redistributable package: the first
# emits instructions that fault on older hardware, the second turns any new
# compiler lint into a build failure. Build for the baseline architecture.
unset RUSTFLAGS || true

export CARGO_PROFILE_RELEASE_DEBUG=false
export CARGO_PROFILE_RELEASE_STRIP=symbols
# Several dependencies resolve from git tags; the CLI honours the build
# environment's proxy and credential configuration where cargo's built-in
# fetcher does not.
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_NET_RETRY=5

# Record the licences of the vendored crate graph; referenced by license_file.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
