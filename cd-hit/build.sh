#!/bin/sh
make -j

mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin
