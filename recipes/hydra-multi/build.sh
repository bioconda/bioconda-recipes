#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
make all CXX="${CXX}" \
    ZLIB_PATH="${PREFIX/lib}" \
    CXXFLAGS="${CXXFLAGS}" \
    LIBS="${LDFLAGS} -lm -lz -lpthread"

chmod 755 hydra-multi.sh
chmod 755 scripts/hydraToBreakpoint.py
sed 's[/usr/local/bin/python2.6[/usr/bin/env python[' -i scripts/frequency.py
cp bin/* $PREFIX/bin
cp scripts/* $PREFIX/bin
cp hydra-multi.sh $PREFIX/bin
