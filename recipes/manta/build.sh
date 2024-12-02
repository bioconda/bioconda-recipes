#!/bin/bash
set -eu

mkdir build ; cd build
BOOST_ROOT=${PREFIX} ../configure --prefix=${PREFIX}
make -j ${CPU_COUNT}			# fails to build / breaks the infrastructure for default '-j ' with no limit.
make install
    
