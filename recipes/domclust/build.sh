#!/bin/bash

make
# copy binary to prefix folder
cp -p bin/domclust $PREFIX/bin
cp -p Script/addtit.pl $PREFIX/bin
cp -p Script/cmpr.pl $PREFIX/bin
cp -p Script/convgraph.pl $PREFIX/bin
cp -p build_input/blast2homfile.pl $PREFIX/bin
cp -p build_input/fasta2genefile.pl $PREFIX/bin

# test
bin/domclust -h
bin/domclust tst/test.hom tst/test.gene

