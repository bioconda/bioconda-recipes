#!/usr/bin/env bash

mkdir build
cd build

DCMTK_HOME=$PREFIX \
cmake \
	-D CMAKE_FIND_ROOT_PATH=${PREFIX} \
	-D CMAKE_INSTALL_PREFIX=${PREFIX} \
        -D CMAKE_BUILD_TYPE:STRING=Release \
	-D DCMTK_WITH_OPENSSL:BOOL=True \
	-D DCMTK_WITH_PNG:BOOL=True \
	-D DCMTK_WITH_THREADS:BOOL=True \
	-D DCMTK_WITH_TIFF:BOOL=True \
	-D DCMTK_WITH_XML:BOOL=True \
	-D DCMTK_WITH_ZLIB:BOOL=True \
	..

make -j${CPU_COUNT} all
make install

mkdir ${PREFIX}/include/dcmtk/dcmjpeg/libijg8/
cp -R ../dcmjpeg/libijg8/*.h ${PREFIX}/include/dcmtk/dcmjpeg/libijg8/
