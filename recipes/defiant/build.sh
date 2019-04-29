#!/bin/bash

export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

# Fix defiant.c for OSX
if [ `uname` == Darwin ]; then
    sed -i.bak 's/restrict argv\[\]/argv\[\]/g' defiant.c
fi

# Compile binaries
${CC} -O4 -o defiant defiant.c -Wall -pedantic -std=gnu11 -lm -fopenmp -I${PREFIX}/include $CFLAGS $LDFLAGS 
mv regions_of_interest regions_of_interest.c
${CC} -o roi regions_of_interest.c -lm -Wall -std=gnu11 -Wextra -pedantic -Wconversion $CFLAGS $LDFLAGS

# Copy binaries
cp defiant ${PREFIX}/bin/defiant
cp roi ${PREFIX}/bin/roi
