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
  bash -x ./scripts/install_hpc_sdk.sh
  source setup_nv_h5.sh
fi

pushd sucpp
make main
make api
make test
./test_su
popd

$PYTHON -m pip install --no-deps --ignore-installed .
