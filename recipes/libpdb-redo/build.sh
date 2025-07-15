#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -pthread"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-int-conversion -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3 -pthread"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export CMAKE_THREAD_LIBS_INIT="-lpthread"
export CMAKE_USE_PTHREADS_INIT=1
export CMAKE_HAVE_LIBC_PTHREAD=1

if [[ "${target_platform}" == "osx-"* ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DTHREADS_PREFER_PTHREAD_FLAG=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_FOR_CCP4=OFF \
    -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
    -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
    -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
    ${CONFIG_ARGS}

cmake --build build --config Release --parallel "${CPU_COUNT}"
cmake --install build
