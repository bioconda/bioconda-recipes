#!/bin/bash

make clean
make PREFIX=${PREFIX}
make PREFIX=${PREFIX} install

# copy scripts
chmod +x NBICseq-norm.pl
cp NBICseq-norm.pl ${PREFIX}/bin
chmod +x R/*.R
cp R/*.R ${PREFIX}/bin
