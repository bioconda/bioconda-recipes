#!/bin/bash
make "CC=${CC}" "CFLAGS=${CFLAGS}"
mkdir $PREFIX/bin/
cp XS $PREFIX/bin/
