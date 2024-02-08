#!/bin/bash

set -eux

# prevent header contamination
rm -rf externalTools/

make -j $CPU_COUNT shlib
mkdir -p "$PREFIX"/{bin,lib,include/sonLib}
install sonLib_daemonize.py "${PREFIX}/bin/"
# some header files are named generic enough to warrant namespacing
cp lib/*.h "${PREFIX}/include/sonLib/"
cp lib/*.so "${PREFIX}/lib/"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
