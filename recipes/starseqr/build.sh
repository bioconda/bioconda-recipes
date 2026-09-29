#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -g -O3"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h ssw/src/
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ssw/src/ssw.*
	rm -f ssw/src/*.bak
fi

$PYTHON -m pip install . -vvv --use-pep517 --no-deps --no-build-isolation --no-cache-dir
