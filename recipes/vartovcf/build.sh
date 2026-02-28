#!/bin/bash -e

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

# Pin rust-htslib to 0.46 (last version before bindgen was forced on via hts-sys)
sed -i.bak 's|rust-htslib = "0.51.0"|rust-htslib = "0.46.0"|' Cargo.toml

RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRD

cargo install --no-track --verbose --root "${PREFIX}" --path .
