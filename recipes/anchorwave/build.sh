#!/bin/bash

set -eux

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

if [[ $TARGET_PLATFORM = "Linux" ]]; then
    mkdir -p build/{sse2,sse4.1,avx2,avx512}

    # SSE2
    rm CMakeLists.txt
    ln -sf CMakeLists_sse2.txt CMakeLists.txt
    cd build/sse2
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build build --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse2"
    cd ../..

    # SSE4.1
    rm CMakeLists.txt
    ln -sf CMakeLists_sse4.1.txt CMakeLists.txt
    cd build/sse4.1
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build build --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse4.1"
    cd ../..

    # AVX2
    rm CMakeLists.txt
    ln -sf CMakeLists_avx2.txt CMakeLists.txt
    cd build/avx2
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build build --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx2"
    cd ../..

    # AVX512
    rm CMakeLists.txt
    ln -sf CMakeLists_avx512.txt CMakeLists.txt
    cd build/avx512
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build build --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx512"
    cd ../..

    # wrapper script
    cp -f "${RECIPE_DIR}/anchorwave" "${PREFIX}/bin/anchorwave"
    chmod +x "${PREFIX}/bin/anchorwave"
elif [[ $TARGET_PLATFORM = "macOS" ]]; then
    mkdir -p build/macOS

    # macOS (SSE4.1)
    rm CMakeLists.txt
    ln -sf CMakeLists_MACOSX86.txt CMakeLists.txt
    cd build/macOS
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build build --clean-first --target install -j "${CPU_COUNT}"
else
    echo "TARGET_PLATFORM must be Linux or macOS" >&2
    exit 1
fi
