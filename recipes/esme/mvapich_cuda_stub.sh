#!/bin/bash

# MVAPICH CUDA stub setup for non-GPU hosts

export MPIR_CVAR_ENABLE_GPU=0

export CUDA_HOME="${PREFIX}/targets/x86_64-linux"
if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CUDA_HOME="${PREFIX}/targets/sbsa-linux"
fi

export -f setup_cuda_stubs() {
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${CUDA_HOME}/lib/stubs"
  ln -sf "${CUDA_HOME}/lib/stubs/libcuda.so" "${CUDA_HOME}/lib/stubs/libcuda.so.1" || true
}
