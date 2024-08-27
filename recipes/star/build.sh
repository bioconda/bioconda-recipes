#!/bin/bash

mkdir -p $PREFIX/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Installing STAR for OSX."
    cp -rf bin/MacOSX_x86_64/* $PREFIX/bin
else 
    echo "Building STAR for Linux"
    cd source

    AMD64_SIMD_LEVELS=("avx2" "avx" "sse4.1" "ssse3" "sse3")

    if [ "$(arch)" == "x86_64" ]; then
        for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
            make -j "$(nproc)" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CXXFLAGSextra="-m$SIMD -flto -march=native" LDFLAGSextra="-flto" STAR STARlong
            cp -rf STAR $PREFIX/bin/STAR-$SIMD
            cp -rf STARlong $PREFIX/bin/STARlong-$SIMD
            make clean
        done
        make STAR STARlong
        cp -rf STAR $PREFIX/bin/STAR-plain
        cp -rf STARlong $PREFIX/bin/STARlong-plain
        cp ../simd-dispatch.sh $PREFIX/bin/STAR
        cp ../simd-dispatch.sh $PREFIX/bin/STARlong
    else
        make -pj "$(nproc)" STAR STARlong
        cp -rf STAR $PREFIX/bin/STAR
        cp -rf STARlong $PREFIX/bin/STARlong
    fi
fi

chmod 755 $PREFIX/bin/STAR
chmod 755 $PREFIX/bin/STARlong
