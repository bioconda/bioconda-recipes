#!/bin/sh

make all
mkdir -p $PREFIX/bin
cp delly $PREFIX/bin
