#!/bin/bash


export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="-lz -lm -lc -lboost_iostreams -L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p ${PREFIX}/bin

# Install bamtools
cd bamtools
mkdir -p build
cd build
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PWD/../ ..
make
make install
cd ../
if [ -d "lib64" ]
then
	mv lib64 lib
fi
cp ${SRC_DIR}/bamtools/lib/*.so* ${PREFIX}/lib

# Install LRez
cd ../
make CC="$CXX -L${PREFIX}/lib"
cp ${SRC_DIR}/lib/liblrez.so ${PREFIX}/lib

# Copy binaries
cp bin/* ${PREFIX}/bin
