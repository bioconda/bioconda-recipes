#!/bin/bash
set -euxo pipefail

# rustc takes its macOS deployment target from MACOSX_DEPLOYMENT_TARGET and otherwise probes
# the build host, which would stamp the binary with a floor above the SDK it was built against.
if [[ "$(uname)" == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-10.15}"
fi

# The source is a release tarball, not a git checkout: record the release as the revision
# (`spearfish --version` and every output's provenance report it).
export SPEARFISH_GIT="v${PKG_VERSION}"

# Licenses of the Rust dependencies compiled into the binary.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1 cargo install --verbose --locked --no-track \
    --root "${PREFIX}" --path crates/spearfish-cli
