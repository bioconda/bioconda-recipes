#!/bin/bash

set -ex

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak -e 's|0.45.0|0.49.0|' Cargo.toml
sed -i.bak -e 's|0.20.3|0.21.2|' Cargo.toml
rm -rf *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

$PYTHON -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir
