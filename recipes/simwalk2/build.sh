#!/bin/bash

tar xf SimWalk2-2.91*
cd SimWalk291
export LIBRARY_PATH=${PREFIX}/lib
gcc -o simwalk2 CODE/nomendel.f CODE/simwalk2.f -lgfortran -lm
mkdir -p ${PREFIX}/bin
cp simwalk2 $PREFIX/bin/
