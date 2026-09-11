#!/bin/bash
set -euxo pipefail
unamestr=`uname`

# rustc picks its -mmacosx-version-min from MACOSX_DEPLOYMENT_TARGET; when the
# variable is absent it falls back to probing the host, which on GitHub's
# runners is whatever macOS the image ships (26.0 today). That stamps binaries
# with a deployment floor far above the SDK (11.3) they were compiled against,
# and above what the recipe promises in its `__osx >=` run constraint.
if [[ "$unamestr" == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-10.15}"
fi

mv .cargo/config-portable.toml .cargo/config.toml

RUST_BACKTRACE=1 cargo install -vv \
    --locked \
    --root "$PREFIX" \
    --path .
