#!/bin/bash
set +ex
export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

if [[ "$(uname -s)" == "Linux" ]];
then
  which x86_64-conda-linux-gnu-gcc
  x86_64-conda-linux-gnu-gcc -v
  x86_64-conda-linux-gnu-g++ -v
else
  which clang
  clang -v
fi

if [[ "$(uname -s)" == "Linux" ]];
then
  echo "====list lib64===="
  echo ${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64
  ls -l ${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64/crt*

  echo "====installing===="
  # Patch install script to use inline fetch and untar
  sed -i 's/tar /#tar /g' ./scripts/install_hpc_sdk.sh
  sed -i 's/rm /#rm /g' ./scripts/install_hpc_sdk.sh
  sed -i 's/wget -q \(.*\)gz/curl https://developer.download.nvidia.com/hpc-sdk/20.9/nvhpc_2020_209_Linux_x86_64_cuda_11.0.tar.gz | tar xpzf -/g' ./scripts/install_hpc_sdk.sh
  bash -x ./scripts/install_hpc_sdk.sh
  # patch localrc to find crt1.o
  echo "set DEFSTDOBJDIR=${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64;" >> hpc_sdk/*/*/compilers/bin/localrc
  echo "====localrc===="
  cat hpc_sdk/*/*/compilers/bin/localrc
  echo "===="
  source setup_nv_h5.sh
fi

pushd sucpp
make main
make api
make test
./test_su
popd

$PYTHON -m pip install --no-deps --ignore-installed .
