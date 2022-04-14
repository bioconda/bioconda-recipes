#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
rm -rf build
mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS -DUSE_NEW_CXX" ..
make -j2

mkdir -p $PREFIX/bin/

cp bin/minia ${PREFIX}/bin/
cp bin/merci ${PREFIX}/bin/
chmod +x $PREFIX/bin/minia
chmod +x $PREFIX/bin/merci

cp ext/gatb-core/bin/gatb-h5dump ${PREFIX}/bin/
chmod +x $PREFIX/bin/gatb-h5dump

