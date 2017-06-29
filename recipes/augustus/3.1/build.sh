#!/bin/sh
make
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config
mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/scripts/
mv config/* $PREFIX/config/
