#!/bin/bash
#sed -i 's/CC =/CC ?=/g' Makefile
#sed -i 's/CFLAGS =/CFLAGS ?=/g' Makefile
make CC=${CC} CFLAGS=${CFLAGS}
cp XS $PREFIX/bin
