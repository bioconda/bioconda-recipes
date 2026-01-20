#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p $PREFIX/bin

sed -i.bak 's|CPP=g++|CPP?=$(CXX)|' Makefile
sed -i.bak 's|CPP=g++|CPP?=$(CXX)|' binning/Makefile
sed -i.bak 's|CPP=g++|CPP?=$(CXX)|' genFm9/Makefile
sed -i.bak 's|CPP=g++|CPP?=$(CXX)|' mapping/Makefile
echo "Binning compilation"

cd binning
make all CPP="${CXX}" ILIB="-I${PREFIX}/include -L${PREFIX}/lib"

install -v -m 0755 binning $PREFIX/bin
cd ..

echo "genFm9 compilation"
cd genFm9
make all CPP="${CXX}" ILIB="-I${PREFIX}/include -L${PREFIX}/lib"
install -v -m 0755 genFm9 $PREFIX/bin
cd ..

echo "mapping compilation"
cd mapping
make all CPP="${CXX}" ILIB="-I${PREFIX}/include -L${PREFIX}/lib"
install -v -m 0755 mapping $PREFIX/bin
cd ..

echo "clame compilation"
make all CPP=${CXX} ILIB="-I${PREFIX}/include -L${PREFIX}/lib"
install -v -m 0755 clame $PREFIX/bin

echo "Installation successful"
