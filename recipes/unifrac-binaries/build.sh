#!/bin/bash
set +ex
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

echo "=== PREIX ==="
env |grep PREFIX

echo "Arch: $(uname -s)"
pwd

if [[ "$(uname -s)" == "Linux" ]];
then
          which x86_64-conda-linux-gnu-gcc
          x86_64-conda-linux-gnu-gcc -v
          x86_64-conda-linux-gnu-g++ -v
else
          which clang
          clang -v
fi
which h5c++
if [[ "$(uname -s)" == "Linux" ]];
then
          ./scripts/install_hpc_sdk.sh
          source setup_nv_h5.sh
fi

make api && \
make main && \
make install

make test

