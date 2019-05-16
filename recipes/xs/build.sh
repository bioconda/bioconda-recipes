#!/bin/bash
make "CC=${CC}" "CFLAGS=${CFLAGS}"
cp XS $PREFIX/bin
