#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/bin/bin"
export M4="${BUILD_PREFIX}/bin/m4"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

cd muscle

autoreconf -if 
if [[ `uname` == Darwin ]]; then
    sed -i.bak '' '/bin_PROGRAMS/d' ./libMUSCLE/Makefile.am
    ./configure --prefix="$PREFIX" CXX="${CXX}" \
	CXXFLAGS='${CXXFLAGS} -O3 -fopenmp -I${PREFIX}/include' \
	LDFLAGS="${LDFLAGS}" --disable-shared 
else
    sed -i.bak '/bin_PROGRAMS/d' ./libMUSCLE/Makefile.am
    ./configure --prefix="$PREFIX" CXX="${CXX}" \
	CXXFLAGS='${CXXFLAGS} -O3 -fopenmp -I${PREFIX}/include' \
	LDFLAGS="${LDFLAGS}"
fi
make -j"${CPU_COUNT}"
make install

cd ..

autoreconf -if
./configure CXX="${CXX}" CXXFLAGS='${CXXFLAGS} -O3 -I${PREFIX}/include' \
	LDFLAGS="${LDFLAGS}" --with-libmuscle="$PREFIX/include"
make LDADD="$LDADD -lMUSCLE-3.7" -j"${CPU_COUNT}"
make install

rm -R muscle/libMUSCLE
rm -R muscle/autom4te.cache
rm -R muscle/m4

install -v -m 0755 parsnp extend.py logger.py partition.py template.ini $PREFIX/bin
install -v -m 0755 src/parsnp_core $PREFIX/bin/bin
cp -R bin $PREFIX/bin 
cp -R examples $PREFIX/bin
