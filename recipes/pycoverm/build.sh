#!/bin/bash

set -ex

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak -e 's|0.45.0|0.49.0|' Cargo.toml
rm -rf *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1
$PYTHON -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir
