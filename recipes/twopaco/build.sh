#!/bin/bash
export CXXFLAGS=`sed "s# -fvisibility-inlines-hidden##g" "$CXXFLAGS"`

mkdir build 
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=11 \
    -DTBB_LIB_DIR="${PREFIX}/lib" \
    -DTBB_INCLUDE_DIR="${PREFIX}/include" \
    ../src
make

install -d "${PREFIX}/bin"
install \
    graphconstructor/twopaco \
    graphdump/graphdump \
    "${PREFIX}/bin/"
