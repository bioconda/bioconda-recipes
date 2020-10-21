#!/bin/bash

mkdir -p ${PREFIX}/bin

make clean
make PREFIX=${PREFIX}
make PREFIX=${PREFIX} install

# copy scripts
chmod +x *.pl
cp *.pl ${PREFIX}/bin/
chmod +x R/*.R
cp R/*.R ${PREFIX}/bin/
