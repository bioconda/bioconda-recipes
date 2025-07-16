#!/bin/bash
mkdir -p $PREFIX/share
mkdir -p $PREFIX/bin
./configure
make
#copy binary to bin
cp -p src/r2r $PREFIX/bin
#copy test files to share
cp -p demo/demo1.sto $PREFIX/share/
cp -p demo/intermediate/demo1.cons.sto $PREFIX/share/
