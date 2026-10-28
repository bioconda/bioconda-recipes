#!/bin/bash
set -exuo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

make -j"${CPU_COUNT}" PREFIX="${PREFIX}" CC="$CC" -C Misc/Applications/Knotinframe all
make -j"${CPU_COUNT}" PREFIX="${PREFIX}" CC="$CC" -C Misc/Applications/Knotinframe install-program
make -j"${CPU_COUNT}" PREFIX="${PREFIX}" CC="$CC" -C Misc/Applications/lib install

chmod 755 $PREFIX/bin/knotinframe* $PREFIX/bin/addRNA*
