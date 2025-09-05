#!/bin/bash

# cppyy's genreflex hard-codes file paths into the SO.
# so, we need to make sure the headers are in their final
# resting place during generation
mv include/boink ${PREFIX}/include/
sed -i '14i#include <array>' ${PREFIX}/include/boink/processors.hh
sed -i '1i#include <cstdint>' ${PREFIX}/include/boink/hashing/kmer_span.hh
export CONDA_BUILD_DEPLOY=1

export CXXFLAGS="${CXXFLAGS} -std=c++17 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ "$(uname -m)" = "aarch64" ]; then
    echo "Building on ARM64 platform, disabling x86-specific optimizations"
    export CXXFLAGS="${CXXFLAGS} -DNO_X86_INSTRUCTIONS"
    
    if [ -f "src/boink/storage/cqf/gqf.c" ]; then
        echo "Patching gqf.c for ARM compatibility..."
        sed -i 's/popcnt x[0-9]*,x[0-9]*/__builtin_popcountll/g' src/boink/storage/cqf/gqf.c
        sed -i 's/bsr x[0-9]*,x[0-9]*/63 - __builtin_clzll/g' src/boink/storage/cqf/gqf.c
    else
        echo "Warning: src/boink/storage/cqf/gqf.c not found, cannot patch for ARM"
    fi
fi

# now do build
mkdir build
cd build

# we don't have git tags so set version manually
export BOINK_VERSION=${PKG_VERSION}

CONDA_PREFIX=${PREFIX} cmake .. -DENABLE_CQF=OFF \
                                -DCMAKE_BUILD_TYPE=Release \
                                -DCMAKE_INSTALL_PREFIX=${PREFIX} \
                                -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
                                -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
                                -DBUILD_SHARED_LIBS=TRUE \
                                -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
                                -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
				-DCMAKE_CXX_STANDARD=17 \
                                -DCMAKE_CXX_FLAGS="-I${PREFIX}/include" \
				-DNO_X86_OPTIMIZATIONS=$(if [ "$(uname -m)" = "aarch64" ]; then echo "ON"; else echo "OFF"; fi)
make install VERBOSE=1
