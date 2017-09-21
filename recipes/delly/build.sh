#!/bin/sh


# build parallel version of delly (using openmp).
make PARALLEL=1 all
mkdir -p $PREFIX/bin
cp src/delly src/dpe src/cov $PREFIX/bin
