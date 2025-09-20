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
          which aarch64-conda-linux-gnu-gcc
          aarch64-conda-linux-gnu-gcc -v
          aarch64-conda-linux-gnu-g++ -v
else
          which clang
          clang -v
fi
which h5c++

if [[ ${target_platform} == "linux-64" ]] && [[ "x${BUILD_NV_OFFLOAD}" != "xcpu" ]];
        then
          export BUILD_NV_OFFLOAD=acc
          # force an older compiler version, since the default has library compatibility issues
          export NV_URL=https://developer.download.nvidia.com/hpc-sdk/24.7/nvhpc_2024_247_Linux_x86_64_cuda_multi.tar.gz
# 	  export NV_URL=https://developer.download.nvidia.com/hpc-sdk/24.7/nvhpc_2024_247_linux_aarch64_cuda_12.5.tar.gz
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

if [[ ${target_platform}  == "linux-aarch64" ]]; then
	sed -i "46c \\\tBLASLIB += -lgfortran " ./src/Makefile
	sed -i "131c \\\t        CPPFLAGS += -march=native  -mtune=generic " ./src/Makefile 
        sed -i "139c \\\tCPPFLAGS += " ./src/Makefile
	sed -i "141c \\\tCPPFLAGS += -march=native -moutline-atomics -mtune=native "  ./src/Makefile
	sed -i "152c \\\t        CPPFLAGS +=  -march=native -moutline-atomics  -mtune=native " ./src/Makefile
	sed -i "20c \\\t \$(CC)  \$(CPPFLAGS) \$(CFLAGS) -std=c99  -c libssu.c -Wno-implicit-function-declaration -fPIC" combined/Makefile 
	sed -i "17c \\\t\$(CC) \$(CFLAGS)  -march=native -mtune=generic  -std=c99 -O0 -g capi_test.c -I../src -lssu -L\${PREFIX}/lib -Wl,-rpath,\${PREFIX}/lib \$(LDFLAGS) -o capi_test" test/Makefile
        sed -i "27c \\\ /*__builtin_cpu_init ();*/" combined/libssu.c
	sed -i "28c \\\   bool has_v2  = false; " combined/libssu.c
	sed -i "29c \\\   bool has_v3  = false; " combined/libssu.c
	sed -i "30c \\\   bool has_v4  = false; " combined/libssu.c

	export UNIFRAC_MAX_CPU=basic
	export UNIFRAC_CPU_INFO=Y

fi

make clean && make clean_install && make all

