#!/bin/bash

mkdir src

find . -maxdepth 1 -mindepth 1 -not -name src -exec mv {} src/ \;

cd src

mkdir ../bin
mkdir ../obj
mkdir ../graphs

mkdir ../localBamTools

pushd .
pushd ../localBamTools
git clone https://github.com/pezmaster31/bamtools
mkdir bamtools/build
pushd bamtools/build  
cmake -DCMAKE_INSTALL_PREFIX=../../install -DCMAKE_INSTALL_BINDIR=bin -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include ..
make
make install
popd; popd; popd

sed -i.bak 's/CXX    = g++//g' makefile
sed -i.bak 's/BOOST_INCLUDE = $(BOOST_PATH)/BOOST_INCLUDE = $(PREFIX)/g' makefile
sed -i.bak 's/BOOST_LIB = $(BOOST_PATH)/BOOST_LIB = $(PREFIX)/g' makefile
sed -i.bak 's/BAMTOOLS_INCLUDE = $(BAMTOOLS_PATH)\/include\/bamtools/BAMTOOLS_INCLUDE = ..\/localBamTools\/install\/include\/bamtools\//g' makefile
sed -i.bak 's/BAMTOOLS_LIB = $(BAMTOOLS_PATH)\/lib64//g' makefile
sed -i.bak 's/BAMTOOLS_SRC = $(BAMTOOLS_PATH)\/src//g' makefile
sed -i.bak 's/-lbamtools/..\/localBamTools\/install\/lib\/libbamtools.a/g' makefile
sed -i.bak 's/^workingDir=.*//g' paths.ini
sed -i.bak 's/^workingDir_HLA_ASM=.*//g' paths.ini

make all 

cd ..

mkdir -p $PREFIX/opt/hla-la
mv ./* $PREFIX/opt/hla-la

ln -s $PREFIX/opt/hla-la/src/HLA-LA.pl $PREFIX/bin/HLA-LA.pl
ln -s $PREFIX/opt/hla-la/src/HLA-ASM.pl $PREFIX/bin/HLA-ASM.pl
