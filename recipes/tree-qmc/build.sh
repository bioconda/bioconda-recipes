#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

cd external/MQLib
make CXX="${GXX}" -j4

cd ../../
"${CXX}" -std=c++11 -O2 -I external/MQLib/include -I external/toms743 \
	-o TREE-QMC \
	src/*.cpp external/toms743/toms743.cpp \
	external/MQLib/bin/MQLib.a -lm

cp TREE-QMC $PREFIX/bin/
chmod a+x $PREFIX/bin/TREE-QMC
