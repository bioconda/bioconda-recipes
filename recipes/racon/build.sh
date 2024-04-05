#!/bin/bash

case $(uname -m) in
    x86_64)
        SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
        ;;
    aarch64)
        SPOA_OPTS="-Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON -Dspoa_generate_dispatch=ON"
        ;;
    *)
        ;;
esac

mkdir -p $PREFIX/bin
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -Dracon_build_wrapper=ON ${SPOA_OPTS} ..
make
chmod +w bin/racon_wrapper
make install
cp bin/racon_wrapper ${PREFIX}/bin
