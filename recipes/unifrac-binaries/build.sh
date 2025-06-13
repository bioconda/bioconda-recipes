#!/bin/bash
set -e
set -x
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

echo "=== PREFIX ==="
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

if [[ "$(uname -s)" == "Linux" ]] && [[ "x${BUILD_NV_OFFLOAD}" != "xcpu" ]];
        then
          export BUILD_NV_OFFLOAD=acc
          # force an older compiler version, since the default has library compatibility issues
          export NV_URL=https://developer.download.nvidia.com/hpc-sdk/24.7/nvhpc_2024_247_Linux_x86_64_cuda_multi.tar.gz
          # install PGI locally
          ./scripts/install_hpc_sdk.sh </dev/null
          # get the compilers in the path and set NV_CXX and AMD_CXX
          . ./setup_nv_compiler.sh
          # Disabling AMD compilation for the time being
          # also install the AMD compiler
          #./scripts/install_amd_clang.sh </dev/null
          #. ./setup_amd_compiler.sh
fi
# else, no NV_CXX or AMD_CXX in the env, so no GPU build
# all == build (shlib,bins,tests) and install
make clean && make clean_install && make all

