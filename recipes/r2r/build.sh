#!/bin/bash
cd NotByZasha/infernal-0.7/
./configure
make
cd ../../
cd src
make
#copy binary to bin
cp -p r2r $PREFIX/bin
cd ../demo
make
#copy test files to share
cp -p demo1.sto $PREFIX/share/
cp -p intermediate/demo1.cons.sto $PREFIX/share/

