#!/bin/sh

make
mkdir -p $PREFIX/bin
cp seqstats $PREFIX/bin
