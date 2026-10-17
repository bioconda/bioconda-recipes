#!/bin/bash -e

# libdeflate is vendored C compiled by cc. Modern clang errors on implicit function declarations;
# relax that so the C build succeeds under the conda compilers.
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
