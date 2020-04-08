#!/bin/sh
set -x -e

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"


#compile
make io.o pfscan pfsearch

# copy tools in the bin
mkdir -p ${PREFIX}/bin
cp pfscan pfsearch ${PREFIX}/bin
