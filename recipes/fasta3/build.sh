#!/bin/bash

mkdir -pv ${PREFIX}/bin ${PREFIX}/share
export CFLAGS=-L${PREFIX}/lib
make -C src -f ../make/Makefile.linux_sse2 all
cp {bin/*36,bin/map_db,scripts/*.pl,misc/*.pl} ${PREFIX}/bin
cp -R {doc,data,seq} ${PREFIX}/share
