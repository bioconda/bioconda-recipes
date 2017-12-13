#!/bin/bash

make
# copy binary to prefix folder
if [ -d 'bin-Linux' ] # linux
then
	cp -p bin-Linux/domclust $PREFIX/bin
else # osx
	cp -p bin-Darwin/domclust $PREFIX/bin
fi

cp -p Script/addtit.pl $PREFIX/bin
cp -p Script/cmpr.pl $PREFIX/bin
cp -p Script/convgraph.pl $PREFIX/bin
cp -p build_input/blast2homfile.pl $PREFIX/bin
cp -p build_input/fasta2genefile.pl $PREFIX/bin

# test
if [ -d 'bin-Linux' ] # linux
then
	bin-Linux/domclust -h
	bin-Linux/domclust tst/test.hom tst/test.gene
else # osx
	bin-Darwin/domclust -h
	bin-Darwin/domclust tst/test.hom tst/test.gene
fi

