#!/bin/bash

set -exo pipefail

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -pthread"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-int-conversion -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY -pthread"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export CMAKE_THREAD_LIBS_INIT="-lpthread"
export CMAKE_USE_PTHREADS_INIT=ON
export CMAKE_HAVE_LIBC_PTHREAD=ON

if [[ "${target_platform}" == "linux-"* ]]; then
    export CONFIG_ARGS=""
elif [[ "${target_platform}" == "osx-"* ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DTHREADS_PREFER_PTHREAD_FLAG=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_FOR_CCP4=OFF \
    -Dcifpp_DIR="${PREFIX}/lib/cmake/cifpp" \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    ${CONFIG_ARGS}

cmake --build build --config Release --parallel "${CPU_COUNT}"
cmake --install build
