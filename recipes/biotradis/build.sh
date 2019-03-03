#!/bin/sh
set -x -e
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cp -r bin/* $PREFIX/bin
cp -r lib/* $PREFIX/lib

