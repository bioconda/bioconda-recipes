#!/bin/bash

rm -fr SeqLib
git clone --recursive https://github.com/walaj/SeqLib.git

for FOLDER in $(find . -type d); do
ln -fs $PREFIX/include/zlib.h $FOLDER/zlib.h;
ln -fs $PREFIX/include/zconf.h $FOLDER/zconf.h;
done

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

sed -i 's|CFLAGS=|CFLAGS=-fPIC|g' SeqLib/bwa/Makefile
sed -i 's|CFLAGS=|CFLAGS=-fPIC|g' SeqLib/fermi-lite/Makefile
sed -i 's|CFLAGS   =|CFLAGS=-fPIC|g' SeqLib/htslib/Makefile

sed -i 's|mkdir -p bin && mv src/svaba/svaba bin|mv bin/svaba $PREFIX/bin|g' Makefile.am
sed -i 's|mkdir -p bin && mv src/svaba/svaba bin|mv bin/svaba $PREFIX/bin|g' Makefile.in

./configure CXXFLAGS=-fPIC --prefix=$PREFIX
make
make install

echo "#################"
echo "### DEBUGGING ###"
echo "#################"

echo ""

echo "Current working directory:"
pwd -P

echo ""

echo "Contents of working directory:"
find .
