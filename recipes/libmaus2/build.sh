#!/bin/bash
set -eu
export LIBS="-lstdc++fs -lcurl -lz"

autoreconf -if
autoupdate
./configure --prefix="${PREFIX}" CXX="${CXX}" CC="${CC}" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	--with-snappy --with-io_lib --with-libdeflate \
	--with-libsecrecy --with-nettle \
	--with-lzma --with-gmp

cat config.log

make -j"${CPU_COUNT}"
make install
