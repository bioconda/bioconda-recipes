#!/bin/bash
./configure
make
#copy binary to bin
cp -p src/r2r $PREFIX/bin
#copy test files to share
cd demo
make
cp -p demo1.sto $PREFIX/share/
cp -p intermediate/demo1.cons.sto $PREFIX/share/
