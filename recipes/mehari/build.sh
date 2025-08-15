#!/bin/bash -xeuo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-int-conversion"

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

rm .cargo/config.toml  # remove custom config.toml for now
# export ROCKSDB_LIB_DIR="${PREFIX}/lib"
# export SNAPPY_LIB_DIR="${PREFIX}/lib"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root "${PREFIX}" --path .
