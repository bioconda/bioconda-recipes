#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib
export CMAKE_PREFIX_PATH=${PREFIX}

make -j 2 prefix=${PREFIX} MARCH=core2 sysconfigdir=${PREFIX}/etc NO_GIT=1 \
 USE_SYSTEM_LIBGIT2=1 USE_LLVM_SHLIB=0 USE_SYSTEM_CURL=1 USE_SYSTEM_MPFR=1 \
 USE_SYSTEM_PATCHELF=1 USE_SYSTEM_LIBSSH2=1 USE_SYSTEM_LLVM=1 USE_SYSTEM_BLAS=1 \
 USE_SYSTEM_FFTW=1 USE_SYSTEM_GMP=1 USE_SYSTEM_LAPACK=1 LIBBLAS=-lopenblas \
 LIBBLASNAME=libopenblas.so LIBLAPACK=-lopenblas LIBLAPACKNAME=libopenblas.so \
 install

mv --verbose "$PREFIX/bin/julia" "$PREFIX/bin/julia_"
cp --verbose "$RECIPE_DIR/julia-wrapper.sh" "$PREFIX/bin/julia"
chmod +x "$PREFIX/bin/julia"
