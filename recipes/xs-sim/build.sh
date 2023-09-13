#!/bin/bash
make "CC=${CC}" "CFLAGS=${CFLAGS}"
mkdir -p $PREFIX/bin/
cp XS $PREFIX/bin/
