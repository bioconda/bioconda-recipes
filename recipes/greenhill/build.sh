#!/bin/sh

mkdir -p $PREFIX/bin
cd src
make CXX=$CXX
cp greenhill $PREFIX/bin/
cd ..
