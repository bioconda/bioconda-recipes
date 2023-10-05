#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing STAR for OSX."
    mkdir -p $PREFIX/bin
    cp bin/MacOSX_x86_64/* $PREFIX/bin
else 
    echo "Building STAR for Linux"
    mkdir -p $PREFIX/bin
    cd source

    AMD64_SIMD_LEVELS=("avx2" "avx" "sse4.1" "ssse3" "sse3")

    if [ "$(arch)" == "x86_64" ]; then
        for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
            make -j "$(nproc)" CXXFLAGSextra="-m$SIMD" STAR STARlong
            cp STAR $PREFIX/bin/STAR-$SIMD
            cp STARlong $PREFIX/bin/STARlong-$SIMD
            make clean
        done
        make STAR STARlong
        cp STAR $PREFIX/bin/STAR-plain
        cp STARlong $PREFIX/bin/STARlong-plain
        cp ../simd-dispatch.sh $PREFIX/bin/STAR
        cp ../simd-dispatch.sh $PREFIX/bin/STARlong
    else
        make pj "$(nproc)" STAR STARlong
        cp STAR $PREFIX/bin/STAR
        cp STARlong $PREFIX/bin/STARlong
    fi
fi

chmod +x $PREFIX/bin/STAR
chmod +x $PREFIX/bin/STARlong
