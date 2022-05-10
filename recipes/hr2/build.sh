#!/bin/sh

mkdir -pv $PREFIX/bin/HR2/bin

"${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} HR2.cpp -o $PREFIX/bin/HR2/bin/HR2.exe
chmod a+x $PREFIX/bin/HR2/bin/HR2.exe

cp $PREFIX/bin/HR2/bin/HR2.exe ${PREFIX}/bin
