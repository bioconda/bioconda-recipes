#!/bin/bash

set -eux

# build in order of dependency structure
make -j $CPU_COUNT api.libs
make -j $CPU_COUNT liftover.libs
make -j $CPU_COUNT lod.libs maf.libs
make -j $CPU_COUNT libs
make -j $CPU_COUNT progs

cp bin/* "${PREFIX}/bin"
cp lib/* "${PREFIX}/lib"
cp */inc/*.h "${PREFIX}/include"

$PYTHON -m pip install --ignore-installed --no-deps -vv .
