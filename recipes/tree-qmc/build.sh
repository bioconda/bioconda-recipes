#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LFLAGS="${LFLAGS} -L${PREFIX}/lib"
export CFLAGS="-std=c++11 -O3 -Wall -I${PREFIX}/include"

cd external/MQLib
make GXX="${GXX}" CFLAGS="${CFLAGS}" LFLAGS="${LFLAGS}" -j4

cd ../../
"${GXX}" -std=c++11 -O3 -I external/MQLib/include -I external/toms743 \
	-o TREE-QMC \
	src/*.cpp external/toms743/toms743.cpp \
	external/MQLib/bin/MQLib.a -lm

cp TREE-QMC $PREFIX/bin/
chmod a+x $PREFIX/bin/TREE-QMC
