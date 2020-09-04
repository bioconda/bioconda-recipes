#!/bin/bash

# Fix zlib error
export CPATH=${PREFIX}/include

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

# Fix some error can't be patch
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' -e "s#CXX= g++#CXX= ${CXX}#" BMEAN/makefile # Fix c++ compiler in BMEAN
    sed -i '' -e "s#CC = gcc#CC = ${CC}#" BMEAN/Complete-Striped-Smith-Waterman-Library/src/Makefile # Fix c compiler in Complete-Striped-Smith-Waterman-Library
    sed -i '' -e "s#CXX = g++#CXX = ${CXX}#" BMEAN/Complete-Striped-Smith-Waterman-Library/src/Makefile # Fix c++ compiler in Complete-Striped-Smith-Waterman-Library
    sed -i '' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp # Fix matrix path
else
    sed -i'' -e "s#CXX= g++#CXX= ${CXX}#" BMEAN/makefile # Fix c++ compiler in BMEAN
    sed -i'' -e "s#CC = gcc#CC = ${CC}#" BMEAN/Complete-Striped-Smith-Waterman-Library/src/Makefile # Fix c compiler in Complete-Striped-Smith-Waterman-Library
    sed -i'' -e "s#CXX = g++#CXX = ${CXX}#" BMEAN/Complete-Striped-Smith-Waterman-Library/src/Makefile # Fix c++ compiler in Complete-Striped-Smith-Waterman-Library
    sed -i'' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp # Fix matrix path
fi

# build 
./install.sh

# rename some binary
mv bin/explode bin/CONSENT-explode
mv bin/merge bin/CONSENT-merge
mv bin/reformatPAF.py bin/CONSENT-reformatPAF.py

# install matrix
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp BMEAN/BOA/blosum80.mat $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

# install bin
cp bin/* $PREFIX/bin/

