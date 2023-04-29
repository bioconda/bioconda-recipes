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
  # we create multiple variants under Linux

  # g++ 10 does not support fancy 2D collapse
  cat > skbio_gcc10.patch << EOF
763c763
< #pragma omp parallel for collapse(2) shared(mat) reduction(+:sum)
---
> #pragma omp parallel for shared(mat) reduction(+:sum)
EOF

  patch src/skbio_alt.cpp skbio_gcc10.patch

  # gcc and fully optimized
  export BUILD_FULL_OPTIMIZATION=True
  make clean && \
  make api && \
  make main && \
  make install

  mv $PREFIX/lib/libssu.so $PREFIX/lib/libssu_cpu.so
  mv $PREFIX/bin/ssu $PREFIX/bin/ssu_cpu
  mv $PREFIX/bin/faithpd $PREFIX/bin/faithpd_cpu

  (cd $PREFIX/lib && ln -s libssu_cpu.so libssu_cpu_avx.so)
  (cd $PREFIX/bin && ln -s ssu_cpu ssu_cpu_avx && ln -s faithpd_cpu faithpd_cpu_avx)

  # gcc with defaults
  export BUILD_FULL_OPTIMIZATION=False
  make clean && \
  make api && \
  make main && \
  make install

  mv $PREFIX/lib/libssu.so $PREFIX/lib/libssu_cpu_basic.so
  mv $PREFIX/bin/ssu $PREFIX/bin/ssu_cpu_basic
  mv $PREFIX/bin/faithpd $PREFIX/bin/faithpd_cpu_basic

  # revert for pgc++
  patch -R src/skbio_alt.cpp skbio_gcc10.patch
  unset BUILD_FULL_OPTIMIZATION
else
  # New ARM chips do not support AVX, so force maximum compatibity
  export BUILD_FULL_OPTIMIZATION=False
fi


if [[ "$(uname -s)" == "Linux" ]];
then
          # remove unused pieces to save space
          cat scripts/install_hpc_sdk.sh |sed 's/tar xpzf/tar --exclude hpcx --exclude openmpi4 --exclude 10.2 -xpzf/g' >my_install_hpc_sdk.sh
          chmod a+x my_install_hpc_sdk.sh
          ./my_install_hpc_sdk.sh
          source setup_nv_h5.sh
fi

make clean && \
make api && \
make main && \
make install

if [[ "$(uname -s)" == "Linux" ]];
then
  # we create multiple variants under Linux

  mv $PREFIX/lib/libssu.so $PREFIX/lib/libssu_nv.so
  mv $PREFIX/bin/ssu $PREFIX/bin/ssu_nv
  mv $PREFIX/bin/faithpd $PREFIX/bin/faithpd_nv

  (cd $PREFIX/lib && ln -s libssu_nv.so libssu.so)
  (cd $PREFIX/bin && ln -s ssu_nv ssu && ln -s faithpd_nv faithpd)

  (cd $PREFIX/lib && ln -s libssu_nv.so libssu_nv_avx.so)
  (cd $PREFIX/bin && ln -s ssu_nv ssu_nv_avx && ln -s faithpd_nv faithpd_nv_avx)
fi

make test

