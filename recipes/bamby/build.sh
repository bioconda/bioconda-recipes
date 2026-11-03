#!/bin/bash -e

# libdeflate and mimalloc are vendored C compiled by cc. Modern clang errors on implicit function
# declarations; relax that so those C builds succeed under the conda compilers.
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --profile dist --root "${PREFIX}" --path .
