#!/bin/bash
rm -f TEpeaks *.a
pushd src/htslib-1.2.1_src
make CC=${CC} CFLAGS="$CFLAGS" prefix=${PREFIX} LDFLAGS="$LDFLAGS"
popd

make CC=${CXX} prefix=${PREFIX}
