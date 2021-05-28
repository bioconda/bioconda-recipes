#!/bin/bash

set -eu -o pipefail

export CPATH=${PREFIX}/include
export CMAKE_LDFLAGS="-L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib

scripts/install.py \
    -c ${CC_FOR_BUILD} \
    -cxx ${CXX_FOR_BUILD} \
    --prefix ${PREFIX}/bin \
    --gmp ${PREFIX} \
    --boost ${PREFIX} \
    --htslib ${PREFIX} \
    --architecture haswell \
    --threads 1 \
    --verbose
