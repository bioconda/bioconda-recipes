#!/bin/bash

export LIBS="-lz -lm -lc -lboost_iostreams"
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
cp "${SRC_DIR}/bamtools/lib/"*"${SHLIB_EXT}"* "${PREFIX}/lib/"

# Install LRez
cd ../
make CC="${CXX} ${LDFLAGS}"
cp "./lib/liblrez${SHLIB_EXT}" "${PREFIX}/lib/"

# Copy binaries
cp bin/* ${PREFIX}/bin
