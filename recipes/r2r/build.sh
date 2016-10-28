#!/bin/bash
cd NotByZasha/infernal-0.7/
./configure
make
cd ../../
cd src
make
./r2r --GSC-weighted-consensus ../demo/demo1.sto ../demo/intermediate/demo1.cons.sto 3 0.97 0.9 0.75 4 0.97 0.9 0.75 0.5 0.1
cp -p r2r $PREFIX/bin 
