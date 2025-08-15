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

sed -i.bak -e 's|VERSION 3.0|VERSION 3.5|' CMakeLists*.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' googletest/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' googletest/googlemock/CMakeLists.txt
sed -i.bak -e 's|VERSION 2.6.4|VERSION 3.5|' googletest/googletest/CMakeLists.txt

rm -rf *.bak
rm -rf googletest/*.bak
rm -rf googletest/googlemock/*.bak
rm -rf googletest/googletest/*.bak

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Linux" && "${ARCH}" == "x86_64" ]]; then
    mkdir -p build/{sse2,sse4.1,avx2,avx512}

    # SSE2
    rm CMakeLists.txt
    ln -sf CMakeLists_sse2.txt CMakeLists.txt
    cd build/sse2
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build . --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse2"
    cd ../..

    # SSE4.1
    rm CMakeLists.txt
    ln -sf CMakeLists_sse4.1.txt CMakeLists.txt
    cd build/sse4.1
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build . --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse4.1"
    cd ../..

    # AVX2
    rm CMakeLists.txt
    ln -sf CMakeLists_avx2.txt CMakeLists.txt
    cd build/avx2
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build . --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx2"
    cd ../..

    # AVX512
    rm CMakeLists.txt
    ln -sf CMakeLists_avx512.txt CMakeLists.txt
    cd build/avx512
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build . --clean-first --target install -j "${CPU_COUNT}"
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx512"
    cd ../..

    # wrapper script
    cp -f "${RECIPE_DIR}/anchorwave" "${PREFIX}/bin/anchorwave"
    chmod +x "${PREFIX}/bin/anchorwave"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
    mkdir -p build/macOS

    # macOS (SSE4.1)
    rm CMakeLists.txt
    ln -sf CMakeLists_MACOSX86.txt CMakeLists.txt
    cd build/macOS
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build . --clean-first --target install -j "${CPU_COUNT}"
elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
    mkdir -p build/arm64

    # arm64
    rm CMakeLists.txt
    ln -sf CMakeLists_arm.txt CMakeLists.txt
    cd build/arm64
    cmake -S ../.. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli "${CONFIG_ARGS}"
    cmake --build . --clean-first --target install -j "${CPU_COUNT}"
else
    echo "TARGET_PLATFORM must be Linux or macOS" >&2
    exit 1
fi
