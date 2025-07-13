#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-int-conversion -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

if [[ "${target_platform}" == "osx-"* ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    ${CONFIG_ARGS}

cmake --build build/ --target install -j "${CPU_COUNT}"
