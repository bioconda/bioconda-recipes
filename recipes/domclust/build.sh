#!/bin/bash

make
# copy binary to prefix folder
cp -p bin/domclust $PREFIX/bin
cp -p Script/addtit.pl $PREFIX/bin
cp -p Script/cmpr.pl $PREFIX/bin
cp -p Script/convgraph.pl $PREFIX/bin
cp -p build_input/blast2homfile.pl $PREFIX/bin
cp -p build_input/fasta2genefile.pl $PREFIX/bin

# copy test data
cp -p tst/test.gene $PREFIX/share
cp -p tst/test.hom $PREFIX/share
cp -p tst/test.out $PREFIX/share

