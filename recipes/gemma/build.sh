#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

LIBS="${PREFIX}/lib/libgsl.a ${PREFIX}/lib/libgslcblas.a -L${PREFIX}/lib -pthread -lopenblas -lz -lgfortran -lquadmath"

if [ $(uname) == "Darwin" ]; then
    PIE=""
else
    PIE="-no-pie"
fi

make EIGEN_INCLUDE_PATH="${PREFIX}/include/eigen3" WITH_OPENBLAS=1 DEBUG=0 GCC_FLAGS="-Wall" LIBS="${LIBS} ${PIE}"

mkdir -p ${PREFIX}/bin
cp bin/gemma ${PREFIX}/bin/gemma
