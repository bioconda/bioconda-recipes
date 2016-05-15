#!/bin/bash

LDFLAGS=-L$PREFIX/lib CFLAGS=-I$PREFIX/include make all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
