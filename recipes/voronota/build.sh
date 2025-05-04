#!/usr/bin/env bash

set -euo pipefail

export CPU_COUNT=1

if [[ "$(uname)" == "Darwin" ]]; then
    # c++11 compatibility
    export CXX="${BUILD_PREFIX}/bin/clang++"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11 -Xpreprocessor -fopenmp -lomp"
    export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lomp -L${PREFIX}/lib -lGLEW -L${PREFIX}/lib -lglfw -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo"
elif [[ "$(uname)" == "Linux" ]]; then
    export CXX="${BUILD_PREFIX}/bin/g++"
    export CXXFLAGS="${CXXFLAGS} -fopenmp"
    export LDFLAGS="${LDFLAGS} -lGLEW -lglfw -lGL -lGLU -lOpenGL"
fi

mkdir build
cd build

cmake .. \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_FRAMEWORK=FIRST \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DEXPANSION_JS=ON \
    -DEXPANSION_LT=ON \
    -DEXPANSION_GL=ON

make -j"${CPU_COUNT}"
make install
