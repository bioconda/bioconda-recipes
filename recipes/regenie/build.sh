#!/bin/bash

# conda install -c huntcloud -c conda-forge "bgenix=1.1.7" boost boost-cpp make c-compiler cxx-compiler fortran-compiler "gxx_linux-64=7.5.0" "gcc_linux-64=7.5.0" "gfortran_linux-64=7.5.0" "libgomp=7.5.0" cxxopts eigen "blas=2.20=mkl" mkl-include

set -e
set -x

if [ "$(uname)" = "Darwin" ]; then
  # LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
  export LDFLAGS="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
fi
export MKL_THREADING_LAYER="GNU"
# export PREFIX="${CONDA_PREFIX}"
# export CPU_COUNT="${CPU_COUNT:=8}"
# export BGEN_PATH="${BGEN_PATH}"
# export SRC_DIR="$(pwd)"

# rm -rf build
mkdir -p build
cd build

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE="Release" \
  -S "${SRC_DIR}"

make -j${CPU_COUNT:=1} regenie
make install
cd ..

# bash test/test_conda.sh --path "${SRC_DIR}" --gz
