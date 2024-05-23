#!/bin/bash

case $(uname -m) in
    x86_64)
        SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
        ;;
    aarch64)
        SPOA_OPTS="-Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON"
        ;;
    *)
        ;;
esac

mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_EXE=ON -DCMAKE_INSTALL_PREFIX=$PREFIX ${SPOA_OPTS} ..
make -j ${CPU_COUNT}
cp bin/raven $PREFIX/bin
