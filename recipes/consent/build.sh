#!/bin/bash

# Fix zlib error
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# Download git submodule dependencie
rm -rf BMEAN
git clone --recursive https://github.com/Malfoy/BMEAN.git
cd BMEAN
git checkout 40ab186c106b2c8303a5605e21d3f4a2e15f809e
cd ..

rm -rf CTPL
git clone --recursive https://github.com/vit-vit/CTPL.git
cd CTPL
git checkout 437e135dbd94eb65b45533d9ce8ee28b5bd3
cd ..

# Fix some error can't be patch before
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp # Fix matrix path
else
    sed -i'' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp # Fix matrix path
fi

# build
cd BMEAN

cd Complete-Striped-Smith-Waterman-Library/src
make default CC=$CC CXX=$CXX CFLAGS="$CFLAGS $LDFLAGS  -Wall -pipe -O2"
cd ../..

cd spoa
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
cd ../..

make CXX=$CXX # BMEAN make
cd ..

make CC="$CXX -std=c++11" # CONSENT make

# rename some binary
mv bin/explode bin/CONSENT-explode
mv bin/merge bin/CONSENT-merge
mv bin/reformatPAF.py bin/CONSENT-reformatPAF.py

# install matrix
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp BMEAN/blosum80.mat $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

# install bin
mkdir -p $PREFIX/bin/
cp bin/* $PREFIX/bin/
cp CONSENT-correct $PREFIX/bin/
cp CONSENT-polish $PREFIX/bin/

