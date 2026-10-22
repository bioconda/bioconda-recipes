#!/bin/bash

export CPPFLAGS="${LDFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

install -d "${PREFIX}/bin"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h external/ssw/
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' external/ssw/ssw.c
	sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' external/ssw/ssw.h
	rm -f external/ssw/*.bak
fi

export PIP_NO_USER_CONFIG_FILE=1
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
