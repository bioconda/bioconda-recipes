#!/bin/bash -eu

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
export RUSTFLAGS="-L ${PREFIX}/include -C link-args=-Wl,-rpath,${PREFIX}/lib"

if [[ "${target_platform}" == "${build_platform}" ]]; then
  export PYO3_PYTHON="${PYTHON}"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install -v --no-track --locked --root "${PREFIX}" --path .

"${STRIP}" "${PREFIX}/bin/orthanq"
