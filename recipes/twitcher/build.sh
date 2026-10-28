#!/bin/bash -euo

# conda-build does not unpack .crate files
tar -xzf "${PKG_NAME}-${PKG_VERSION}.crate"
cd "${PKG_NAME}-${PKG_VERSION}"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1 cargo install --no-track --locked --verbose --path . --root "${PREFIX}"
