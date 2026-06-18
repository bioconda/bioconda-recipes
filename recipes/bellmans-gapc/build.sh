#!/bin/bash
set -xe

export SED="sed"
export SYSTEM_SUFFIX="_linux-gnu"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --with-boost-libdir="${PREFIX}/lib" \
	CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	--prefix="${PREFIX}" --disable-gsltest \
	--disable-option-checking --with-gsl-prefix="${PREFIX}" \
	CC="${CC}" CXX="${CXX}" \
	CFLAGS="${CFLAGS} -O3" CXXFLAGS="${CXXFLAGS} -O3"

# change compile flags if on OSX
if [[ x"$(uname)" == x"Darwin" ]]; then
	export SYSTEM_SUFFIX=`cat config.mf |grep "^SYSTEM_SUFFIX" | cut -d "=" -f2 | tr -d " "`
	$SED -E "s/ -D_XOPEN_SOURCE=500 / /" -i config.mf
	$SED -E "s/ -std=c\+\+17 / -std=c\+\+14 /" -i config.mf
fi

make -j"${CPU_COUNT}" CC="${CC}" CXX="${CXX}"
make install

# remove definition of CXX in user space config file, since this will not match users compiler path,
# instead let conda take care of providing meaningful CXX and CC values.
$SED "s/^CXX = /#CXX = /" -i $PREFIX/share/gapc/config${SYSTEM_SUFFIX}.mf
$SED "s/^CC = /#CC = /" -i $PREFIX/share/gapc/config${SYSTEM_SUFFIX}.mf
