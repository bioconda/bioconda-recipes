#!/bin/bash

# Ensure we run successfully using either conda-forge or defaults ncurses
# (unlike other platforms, the latter does not automatically pull in libtinfo)

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
# export CPATH=${PREFIX}/include
# export CPATH=${BUILD_PREFIX}/bin
# export PKG_CONFIG_EXECUTABLE=${BUILD_PREFIX}/bin/pkg-config

# which pkg-config
# which cmake
# echo "$CPATH"

# sed -i '25 i set(PKG_CONFIG_EXECUTABLE ${PKG_CONFIG_EXECUTABLE})' src/CMakeLists.txt

# cat src/CMakeLists.txt

# cmake ../src

# make CC="${CC}" CXX="${CXX}"

mkdir build
cd build
cmake ../src \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    \
    -DCMAKE_CXX_LINK_FLAGS="${LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}"

make

make install
