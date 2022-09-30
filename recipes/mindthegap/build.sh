#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
rm -rf build
mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS -DUSE_NEW_CXX" ..
make -j2

mkdir -p $PREFIX/bin/

cp bin/MindTheGap ${PREFIX}/bin/
chmod +x $PREFIX/bin/MindTheGap

cp ext/gatb-core/bin/dbgh5 ${PREFIX}/bin/
chmod +x $PREFIX/bin/dbgh5
cp ext/gatb-core/bin/dbginfo ${PREFIX}/bin/
chmod +x $PREFIX/bin/dbginfo

