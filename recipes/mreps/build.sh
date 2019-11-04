#! /bin/bash
mkdir -p $PREFIX/bin
make -j
cp mreps $PREFIX/bin
