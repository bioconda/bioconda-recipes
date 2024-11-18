#!/bin/bash
set -eu
export LIBS="-lstdc++ -lcurl -lz -ldeflate"

autoreconf -if
autoupdate
./configure --prefix="${PREFIX}" CXX="${CXX}" CC="${CC}" \
	CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	--with-snappy --with-io_lib --with-libdeflate \
	--with-libsecrecy --with-nettle \
	--with-lzma --with-gmp

cat config.log

make -j"${CPU_COUNT}"
make install
