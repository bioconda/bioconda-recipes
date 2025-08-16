#!/bin/bash
set -ex

sed -i 's/mpiexec/prterun/g' configure
sed -i 's/mpirun/prterun/g' configure

export CC=mpicc
export CXX=mpicxx
export FC=mpifort

export RUNSERIAL="prterun -n 1"
export RUNPARALLEL="prterun -n \$\${NPROCS:=6}"

cd esme_hdf5

./configure --prefix="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-szlib="${PREFIX}" \
            --enable-fortran \
            --enable-parallel \
            --enable-threadsafe \
            --enable-unsupported \
            --enable-optimization=high \
            --enable-build-mode=production \
            --disable-dependency-tracking \
            --enable-static=no \
            --disable-doxygen-doc

make -j ${CPU_COUNT}
make install
