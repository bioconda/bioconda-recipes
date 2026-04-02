#!/bin/bash
set -ex

export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

case $(uname -m) in
    aarch64|arm64)
        git clone https://github.com/DLTcollab/sse2neon.git
        cp -f sse2neon/sse2neon.h ssw/src/

	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ssw/src/ssw.h
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ssw/src/ssw.c
	rm -f ssw/src/*.bak
	;;
esac

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install -v --locked --no-track --root "$PREFIX" --path .

"${STRIP}" "$PREFIX/bin/mtsv-tools"
