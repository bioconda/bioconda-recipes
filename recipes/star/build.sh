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

    AMD64_SIMD_LEVELS=("avx2" "avx" "sse4.1" "ssse3" "sse3")

    if [[ "$(arch)" == "x86_64" ]]; then
        for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
            make -j"$(nproc)" CXX="${CXX}" CXXFLAGSextra="-m$SIMD" CXXFLAGS="${CXXFLAGS}" STAR STARlong
            cp -rf STAR $PREFIX/bin/STAR-$SIMD
            cp -rf STARlong $PREFIX/bin/STARlong-$SIMD
	    chmod 0755 $PREFIX/bin/STAR-$SIMD
	    chmod 0755 $PREFIX/bin/STARlong-$SIMD
            make clean
        done
        make -j"${CPU_COUNT}" STAR STARlong
        mv STAR $PREFIX/bin/STAR-plain
        mv STARlong $PREFIX/bin/STARlong-plain
        cp -rf ../simd-dispatch.sh $PREFIX/bin/STAR
        cp -rf ../simd-dispatch.sh $PREFIX/bin/STARlong
	chmod 0755 $PREFIX/bin/STAR-plain $PREFIX/bin/STARlong-plain
    else
        make -pj"$(nproc)" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STAR STARlong
        install -v -m 0755 STAR $PREFIX/bin
        install -v -m 0755 STARlong $PREFIX/bin
    fi
fi
