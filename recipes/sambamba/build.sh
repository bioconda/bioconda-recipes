#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# Running `make check` recompiles as an unoptimised binary so must be done prior to release compile
make check CC=${CC}

make release CC=${CC} LIBRARY_PATH=${PREFIX}/lib
make install prefix=${PREFIX}

# The binaries are versioned for some reason
mv ${PREFIX}/bin/sambamba-* ${PREFIX}/bin/sambamba
