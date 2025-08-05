#!/bin/bash -x

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${PREFIX}/lib/pkgconfig"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3"

cd trunk

./autogen.sh
./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules \
	--enable-dependency-tracking CC="${CC}" \
	CXX="${CXX}" CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" BOOST_ROOT="${PREFIX}"

make -j"${CPU_COUNT}"
make install

# Some boost versions require boost_system to be the last in the list of libraries when linking...
sed -i.bak 's|-lboost_system ||' ${PREFIX}/lib/pkgconfig/libMems-1.6.pc
sed -i.bak 's|-lrt|-lboost_system -lrt|' ${PREFIX}/lib/pkgconfig/libMems-1.6.pc
