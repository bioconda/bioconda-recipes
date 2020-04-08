#!/bin/sh
set -x -e

mkdir -p ${PREFIX}/bin

#compile
make io.o pfscan pfsearch

# copy tools in the bin
cp pfscan pfsearch ${PREFIX}/bin
