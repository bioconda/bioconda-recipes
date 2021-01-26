#!/bin/bash

# Fix zlib error
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# Download git submodule dependencie
wget -O - https://github.com/Malfoy/BMEAN/tarball/40ab186c106b2c8303a5605e21d3f4a2e15f809e | tar xvfz - -C BMEAN --strip-components 1
wget -O - https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library/tarball/f0111d3d9e13c3e67e9c7c1b576fa4a6672bf545 | tar xvfz - -C BMEAN/Complete-Striped-Smith-Waterman-Library --strip-components 1
wget -O - https://github.com/rvaser/spoa/tarball/0ed1abf371a8d00dd6b93584449db874e3e7e288 | tar xvfz - -C BMEAN/spoa --strip-components 1

wget -O - https://github.com/vit-vit/CTPL/tarball/437e135dbd94eb65b45533d9ce8ee28b5bd3 | tar xfzv - -C CTPL --strip-components 1

# Fix some error can't be patch before
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp # Fix matrix path
else
    sed -i'' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp # Fix matrix path
fi

# build
make -C BMEAN/Complete-Striped-Smith-Waterman-Library/src default CC=$CC CXX=$CXX CFLAGS="$CFLAGS $LDFLAGS  -Wall -pipe -O2"

mkdir -p BMEAN/spoa/build
cmake -DCMAKE_BUILD_TYPE=Release -BBMEAN/spoa/build BMEAN/spoa/
make -C BMEAN/spoa/build

make -C BMEAN CXX=$CXX # BMEAN make

mkdir -p bin
make CC="$CXX -std=c++11" # CONSENT make

# rename some binary
mv bin/explode bin/CONSENT-explode
mv bin/merge bin/CONSENT-merge
mv bin/reformatPAF bin/CONSENT-reformatPAF

# install matrix
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp BMEAN/blosum80.mat $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

# install bin
mkdir -p $PREFIX/bin/
cp bin/* $PREFIX/bin/
cp CONSENT-correct $PREFIX/bin/
cp CONSENT-polish $PREFIX/bin/

