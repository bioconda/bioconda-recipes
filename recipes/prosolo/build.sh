#!/bin/bash -euo

set -xe

# Make sure bindgen passes on our compiler flags.
# export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
# Can't use BINDGEN_EXTRA_CLANG_ARGS because prosic2 depends on rust-htslib=0.22 which uses bindgen<0.49.
export C_INCLUDE_PATH=$PREFIX/include
cargo install --path . --root $PREFIX --verbose --debug
