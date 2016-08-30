#!/bin/bash

export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
#export CPPFLAGS="-I$PREFIX/include"
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

(
	cd ext
	rm -fr htslib
	git clone git://github.com/samtools/htslib
)

echo "g++"
g++ -v || true
echo "c++"
c++ -v || true
echo "CXX"
$CXX -v || true

sed -i ".bak" 's/cstdio/cerror/g' src/ococo.h

make VERBOSE=1 CXX=g++
mkdir -p ${PREFIX}/bin
cp ococo ${PREFIX}/bin
cp ococo.1 ${PREFIX}/share/man/man1

