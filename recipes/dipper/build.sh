#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p build
cd build

EXTRA_FLAGS="-DCMAKE_BUILD_TYPE=Release -DTBB_DIR=${PREFIX}"

case "${PKG_NAME}" in
dipper)
        cmake .. ${CMAKE_ARGS} ${EXTRA_FLAGS} -DUSE_CUDA=OFF -DUSE_HIP=OFF -DUSE_CPU=ON
        cmake --build . --target install --parallel ${CPU_COUNT}
        cmake --install .
    ;;  
dipper-cuda)
    if command -v nvcc >/dev/null 2>&1; then
	    cmake .. ${CMAKE_ARGS} ${EXTRA_FLAGS} -DUSE_CUDA=ON -DUSE_HIP=OFF -DUSE_CPU=ON
	    cmake --build . --target install --parallel ${CPU_COUNT}
    	cmake --install .
    fi
    ;;
dipper-rocm)
    if command -v hipcc >/dev/null 2>&1; then
    	export CXX=hipcc
    	cmake .. ${CMAKE_ARGS} ${EXTRA_FLAGS} -DUSE_CUDA=OFF -DUSE_HIP=ON -DUSE_CPU=ON
    	cmake --build . --target install --parallel ${CPU_COUNT}
    	cmake --install .
    fi ;;
esac
