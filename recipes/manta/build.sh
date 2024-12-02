#!/bin/bash
set -eu

mkdir build ; cd build
BOOST_ROOT=${PREFIX} ../configure --prefix=${PREFIX}
make -j 
make install
    
