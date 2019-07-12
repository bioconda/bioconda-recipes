#!/bin/sh

make all
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
