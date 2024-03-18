#!/bin/bash

# Install both the pairix binaries and the Python extension module
export INCLUDES="${PREFIX}/include"
export LIBPATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC} ${LDFLAGS}" CFLAGS="${CFLAGS} -O3"

cp util/*.pl $PREFIX/bin/
cp util/*.sh $PREFIX/bin/
cp util/bam2pairs/bam2pairs $PREFIX/bin/
cp bin/pairix $PREFIX/bin/pairix
cp bin/pairs_merger $PREFIX/bin/pairs_merger
cp bin/streamer_1d $PREFIX/bin/streamer_1d

${PYTHON} -m pip install . --no-deps --no-build-isolation -vvv
