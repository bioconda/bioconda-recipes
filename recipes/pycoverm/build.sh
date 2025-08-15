#!/bin/bash

set -ex

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$CC"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="$CC"
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
