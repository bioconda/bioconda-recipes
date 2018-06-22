#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

#sed -i.bak 's:CFLAGS=.*:CFLAGS=-I'"${PREFIX}"'\/include -g -Wall -O2 -Wno-unused-function:g' Makefile
#sed -i.bak 's:seqtk.c -o:'"${LDFLAGS}"' seqtk.c -o:g' Makefile

make all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
