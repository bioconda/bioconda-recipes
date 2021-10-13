#!/bin/sh
set -x -e

# programs intsalled
# pfscanV3 pfsearchV3 pfcalibrateV3 pfemit pfpam pfdump pfindex gtop htop ptoh ptof pfw 2ft 6ft psa2msa pfscale pfsearch pfscan pfmake

cd build/
cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ..
make CC=${CC} CXX=${CXX} F77=${GFORTRAN} CFLAGS="$CFLAGS $LDFLAGS"
make install
make test

ls -l ${PREFIX}/bin
