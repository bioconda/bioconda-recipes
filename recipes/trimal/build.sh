#!/bin/sh

cd source
make CC="${CXX}" FLAGS="${CPPFLAGS} ${CXXFLAGS}" -j ${CPU_COUNT}

mkdir -p $PREFIX/bin

cp readal $PREFIX/bin
cp statal $PREFIX/bin
cp trimal $PREFIX/bin

