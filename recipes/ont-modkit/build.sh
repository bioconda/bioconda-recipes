#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -fcommon -Wno-implicit-function-declaration"
export CXXFLAGS="${CFLAGS} -O3 -fcommon"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install \
	--no-track \
	-v \
	--root "${PREFIX}" \
	--path modkit

rm -rf "${PREFIX}/.crates"* "${PREFIX}/lib"
"${STRIP}" "$PREFIX/bin/modkit"
