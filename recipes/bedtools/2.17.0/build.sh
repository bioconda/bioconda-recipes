#!/bin/sh

make
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/
