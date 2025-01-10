#!/usr/bin/env bash

set -xe

export CFLAGS="-idirafter ${PREFIX}/include" 
export LDFLAGS="-L${PREFIX}/lib"
export LINKFLAGS="-L${PREFIX}/lib"
export EIGEN_CFLAGS="-idirafter ${PREFIX}/include/eigen3"

mkdir -p "${PREFIX}"/{bin,lib,share}

./configure -conda 
./build 
cp -r bin lib share "${PREFIX}"

# debug
ls -la bin/