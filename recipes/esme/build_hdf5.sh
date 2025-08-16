#!/bin/bash
set -ex

export CC=mpicc
export CXX=mpicxx
export FC=mpifort

export RUNSERIAL="prterun -n 1"
export RUNPARALLEL="prterun -n \$\${NPROCS:=6}"

export CFLAGS="-fPIC -O3 -xHost" 
export FFLAGS="-fPIC -O3 -xHost" 
export CXXFLAGS="-fPIC -O3 -xHost" 

cd esme_hdf5

sed -i 's/mpiexec/prterun/g' configure
sed -i 's/mpirun/prterun/g' configure

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
