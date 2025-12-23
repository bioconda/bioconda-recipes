#!/usr/bin/env bash

set -exou pipefail

# Prevent build failures due to insufficient memory in the CI environment
if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
  export CPU_COUNT=1
fi

if [[ "$(uname)" == "Darwin" ]]; then
    # c++11 compatibility
    export CXXFLAGS="${CXXFLAGS} -Xpreprocessor -fopenmp"
    export LDFLAGS="${LDFLAGS} -lomp -lGLEW -lglfw -framework OpenGL"
elif [[ "$(uname)" == "Linux" ]]; then
    export CXXFLAGS="${CXXFLAGS} -fopenmp"
    export LDFLAGS="${LDFLAGS} -lGLEW -lglfw -lGL -lGLU"
fi

# Allow CMake to find framework OpenGL on MacOS
sed -i.bak \
    -e '/target_link_libraries(voronota-gl m GL GLEW glfw)/i\
find_package(OpenGL REQUIRED)
' \
    -e 's/target_link_libraries(voronota-gl m GL GLEW glfw)/target_link_libraries(voronota-gl m OpenGL::GL GLEW glfw)/' \
    expansion_gl/CMakeLists.txt

mkdir build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS}" \
    -DEXPANSION_JS=ON \
    -DEXPANSION_LT=ON \
    -DEXPANSION_GL=ON

make -j"${CPU_COUNT}"
make install
