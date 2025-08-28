#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* m4/

if [[ "$target_platform" == "linux-aarch64" || "$target_platform" == "osx-arm64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h .
	sed -i.bak 's|emmintrin.h|sse2neon.h|' src/crass/ksw.c
	rm -rf src/crass/*.bak
fi

autoreconf -if
./configure --prefix="${PREFIX}" \
	--with-xerces="${PREFIX}" \
	--enable-rendering \
	CPPFLAGS="$CPPFLAGS" \
	LDFLAGS="$LDFLAGS"

make -j"${CPU_COUNT}"
make install
