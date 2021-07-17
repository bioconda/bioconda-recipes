#!/bin/sh

mkdir -p $PREFIX/bin/sub_bin

make CXX=${CXX}
cp metaplatanus $PREFIX/bin
cp src/scripts/tgsgapcloser_mod $PREFIX/bin
cp -r sub_bin/* $PREFIX/bin/sub_bin

cd src/nextpolish
ln -s `which ${CC}` `dirname \`which ${CC}\``/gcc
ln -s `which ${CXX}` `dirname \`which ${CXX}\``/g++
make
ln -s $PREFIX/bin/samtools bin/samtools
ln -s $PREFIX/bin/bwa bin/bwa
ln -s $PREFIX/bin/minimap2 bin/minimaps
cp -r nextPolish lib bin $PREFIX/bin/sub_bin
cd ../..
