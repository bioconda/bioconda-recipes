#!/bin/bash

set -eux

if [ $TARGET_PLATFORM = "Linux" ]; then
    mkdir -p build/{sse2,sse4.1,avx2,avx512}

    # SSE2
    rm CMakeLists.txt
    ln -s CMakeLists_sse2.txt CMakeLists.txt
    cd build/sse2
    cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../..
    make -j"${CPU_COUNT}"
    make install
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse2"
    cd ../..

    # SSE4.1
    rm CMakeLists.txt
    ln -s CMakeLists_sse4.1.txt CMakeLists.txt
    cd build/sse4.1
    cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../..
    make -j"${CPU_COUNT}"
    make install
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse4.1"
    cd ../..

    # AVX2
    rm CMakeLists.txt
    ln -s CMakeLists_avx2.txt CMakeLists.txt
    cd build/avx2
    cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../..
    make -j"${CPU_COUNT}"
    make install
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx2"
    cd ../..

    # AVX512
    rm CMakeLists.txt
    ln -s CMakeLists_avx512.txt CMakeLists.txt
    cd build/avx512
    cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../..
    make -j"${CPU_COUNT}"
    make install
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx512"
    cd ../..

    # wrapper script
    cp "${RECIPE_DIR}/anchorwave" "${PREFIX}/bin/anchorwave"
    chmod +x "${PREFIX}/bin/anchorwave"
elif [ $TARGET_PLATFORM = "macOS" ]; then
    mkdir -p build/macOS

    # macOS (SSE4.1)
    rm CMakeLists.txt
    ln -s CMakeLists_MACOSX86.txt CMakeLists.txt
    cd build/macOS
    cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../..
    make -j"${CPU_COUNT}"
    make install
else
    echo "TARGET_PLATFORM must be Linux or macOS" >&2
    exit 1
fi
