#!/bin/bash -e

set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-int-conversion"

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --root "${PREFIX}" --path .
