#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++17 -O3 -I${PREFIX}/include -fopenmp"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Installing STAR for OSX."
    mkdir -p $PREFIX/bin
    install -v -m 0755 bin/MacOSX_x86_64/STAR $PREFIX/bin
    install -v -m 0755 bin/MacOSX_x86_64/STARlong $PREFIX/bin
else 
    echo "Building STAR for Linux"
    mkdir -p $PREFIX/bin
    cd source
    make -pj"$(nproc)" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STAR STARlong
    install -v -m 0755 STAR $PREFIX/bin
    install -v -m 0755 STARlong $PREFIX/bin
fi
