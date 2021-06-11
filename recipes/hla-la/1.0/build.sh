#!/bin/bash

cd src

mkdir ../bin
mkdir ../obj
mkdir ../graphs

sed -i.bak 's/^workingDir=.*//g' paths.ini
sed -i.bak 's/^workingDir_HLA_ASM=.*//g' paths.ini

make \
  CXX="${CXX}" \
  BOOST_PATH="${PREFIX}" \
  BAMTOOLS_PATH="${PREFIX}" \
  BAMTOOLS_SRC="${PREFIX}/include" \
  BAMTOOLS_LIB="${PREFIX}/lib" \
  all

cd ..

mkdir -p $PREFIX/opt/hla-la
mv ./bin ./graphs ./src $PREFIX/opt/hla-la/

ln -s $PREFIX/opt/hla-la/src/HLA-LA.pl $PREFIX/bin/HLA-LA.pl
ln -s $PREFIX/opt/hla-la/src/HLA-ASM.pl $PREFIX/bin/HLA-ASM.pl
