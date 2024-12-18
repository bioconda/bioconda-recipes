#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/bin/bin"

cd muscle

./autogen.sh
autoreconf -if
if [[ `uname` == "Darwin" ]]; then
    sed -i.bak '' '/bin_PROGRAMS/d' ./libMUSCLE/Makefile.am
    ./configure --prefix="$PREFIX" CXX="${CXX}" CXXFLAGS='${CXXFLAGS} -O3 -fopenmp' --disable-shared 
else
    sed -i.bak '/bin_PROGRAMS/d' ./libMUSCLE/Makefile.am
    ./configure --prefix="$PREFIX" CXX="${CXX}" CXXFLAGS='${CXXFLAGS} -O3 -fopenmp'
fi
make -j"${CPU_COUNT}"
make install

cd ..

./autogen.sh
autoreconf -if
./configure CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3" --with-libmuscle="$PREFIX/include"
make LDADD="$LDADD -lMUSCLE-3.7" -j"${CPU_COUNT}"
make install

rm -R muscle/libMUSCLE
rm -R muscle/autom4te.cache
rm -R muscle/m4

install -v -m 0755 parsnp $PREFIX/bin
cp extend.py $PREFIX/bin
cp logger.py $PREFIX/bin
cp partition.py $PREFIX/bin
install -v -m 0755 src/parsnp_core $PREFIX/bin/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R examples $PREFIX/bin
