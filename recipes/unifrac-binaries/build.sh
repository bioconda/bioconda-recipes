#!/bin/bash
set -e
set -x
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
  # Temporary workaround
  # g++ 10 does not support fancy 2D collapse
  cat > skbio_gcc10.patch << EOF
763c763
< #pragma omp parallel for collapse(2) shared(mat) reduction(+:sum)
---
> #pragma omp parallel for shared(mat) reduction(+:sum)
EOF

  patch src/skbio_alt.cpp skbio_gcc10.patch
fi


if [[ "$(uname -s)" == "Linux" ]];
then
          # remove unused pieces to save space
          cat scripts/install_hpc_sdk.sh |sed 's/tar xpzf/tar --exclude hpcx --exclude openmpi4 --exclude 10.2 -xpzf/g' >my_install_hpc_sdk.sh
          chmod a+x my_install_hpc_sdk.sh
          ./my_install_hpc_sdk.sh
          # install PGI but do not source it
          # the makefile will do it automatically
fi

# all == build (shlib,bins,tests) and install
make all

make test

