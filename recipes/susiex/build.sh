#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make LDFLAGS="-L$PREFIX/lib -O3 -flto"
cp ../bin/SuSiEx $PREFIX/bin/SuSiEx
