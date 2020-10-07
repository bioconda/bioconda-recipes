#!/usr/bin/env bash

mkdir build
cd build

DCMTK_HOME="${PREFIX}" \
cmake \
    -D CMAKE_FIND_ROOT_PATH="${PREFIX}" \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D DCMTK_WITH_OPENSSL:BOOL=TRUE \
    -D DCMTK_WITH_PNG:BOOL=TRUE \
    -D DCMTK_WITH_THREADS:BOOL=TRUE \
    -D DCMTK_WITH_TIFF:BOOL=TRUE \
    -D DCMTK_WITH_XML:BOOL=TRUE \
    -D DCMTK_WITH_ZLIB:BOOL=TRUE \
    -D BUILD_SHARED_LIBS:BOOL=TRUE \
    -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE \
    ..

make -j"${CPU_COUNT}" all
make install

mkdir -p "${PREFIX}/include/dcmtk/dcmjpeg/libijg8"
cp ../dcmjpeg/libijg8/*.h "${PREFIX}/include/dcmtk/dcmjpeg/libijg8/"
