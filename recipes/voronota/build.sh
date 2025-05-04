#!/usr/bin/env bash

set -exou pipefail

export CPU_COUNT=1

if [[ "$(uname)" == "Darwin" ]]; then
    # c++11 compatibility
    export CXXFLAGS="${CXXFLAGS} -std=c++11 -Xpreprocessor -fopenmp"
    export LDFLAGS="${LDFLAGS} -lomp -lGLEW -lglfw -framework OpenGL"
elif [[ "$(uname)" == "Linux" ]]; then
    export CXXFLAGS="${CXXFLAGS} -fopenmp"
    export LDFLAGS="${LDFLAGS} -lGLEW -lglfw -lGL -lGLU -lOpenGL"
fi

mkdir build && cd build

cmake .. \
    "${CMAKE_ARGS}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DEXPANSION_JS=ON \
    -DEXPANSION_LT=ON \
    -DEXPANSION_GL=ON

make -j"${CPU_COUNT}"
make install
