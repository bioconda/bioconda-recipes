#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++14 -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Installing STAR for OSX."
    mkdir -p $PREFIX/bin
    cp -rf bin/MacOSX_x86_64/* $PREFIX/bin
else 
    echo "Building STAR for Linux"
    mkdir -p $PREFIX/bin
    cd source

    AMD64_SIMD_LEVELS=("avx2" "avx" "sse4.1" "ssse3" "sse3")

    if [[ "$(arch)" == "x86_64" ]]; then
        for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
            make -j"$(nproc)" CXX="${CXX}" CXXFLAGSextra="-m$SIMD" CXXFLAGS="${CXXFLAGS}" STAR STARlong
            cp -rf STAR $PREFIX/bin/STAR-$SIMD
            cp -rf STARlong $PREFIX/bin/STARlong-$SIMD
            make clean
        done
        make -j"${CPU_COUNT}" STAR STARlong
        cp -rf STAR $PREFIX/bin/STAR-plain
        cp -rf STARlong $PREFIX/bin/STARlong-plain
        cp -rf ../simd-dispatch.sh $PREFIX/bin/STAR
        cp -rf ../simd-dispatch.sh $PREFIX/bin/STARlong
    else
        make -pj"$(nproc)" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STAR STARlong
        install -v -m 0755 STAR $PREFIX/bin
        install -v -m 0755 STARlong $PREFIX/bin
    fi
fi

chmod 0755 $PREFIX/bin/STAR
chmod 0755 $PREFIX/bin/STARlong
