#!/usr/bin/env bash

mkdir build
cd build

# WARNING: with the default value of USE_COMPILER_HIDDEN_VISIBILITY (TRUE/ON),
# link problems arise when linking (at least) ofstd.
# WARNING: CMAKE_INSTALL_LIBDIR defaults to lib64, while conda expects lib
cmake \
    -G Ninja \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D BUILD_SHARED_LIBS:BOOL=TRUE \
    -D USE_COMPILER_HIDDEN_VISIBILITY:BOOL=FALSE \
    -D CMAKE_INSTALL_LIBDIR:PATH=lib \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D ICU_ROOT="${CONDA_PREFIX}" \
    -D OPENSSL_ROOT_DIR="${CONDA_PREFIX}" \
    -D DCMTK_ENABLE_PRIVATE_TAGS:BOOL=TRUE \
    ..

cmake --build . --target install

mkdir -p "${PREFIX}/include/dcmtk/dcmjpeg/libijg8"
cp ../dcmjpeg/libijg8/*.h "${PREFIX}/include/dcmtk/dcmjpeg/libijg8/"
