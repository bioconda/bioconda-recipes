#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* config/

autoreconf -if
./configure --prefix="$PREFIX" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" || (cat config.log ; exit 1)

make AUTOMAKE="$(which automake)" AUTOCONF="$(which autoconf)"
make install
