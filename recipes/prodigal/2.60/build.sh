#!/bin/sh
mkdir -p $PREFIX/bin
make
mv prodigal $PREFIX/bin
