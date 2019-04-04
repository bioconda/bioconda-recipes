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

echo "#################"
echo "### DEBUGGING ###"
echo "#################"

echo ""

echo "Current working directory:"
pwd -P

echo ""

echo "Contents of working directory:"
find .

echo ""

echo "Moving in Makefiles before sed"

grep "src/svaba/svaba" Makefile.am
grep "src/svaba/svaba" Makefile.in

echo ""

sed -i 's|mkdir -p bin && mv src/svaba/svaba bin|mv bin/svaba $PREFIX/bin|g' Makefile.am
sed -i 's|mkdir -p bin && mv src/svaba/svaba bin|mv bin/svaba $PREFIX/bin|g' Makefile.in

echo "Moving in Makefiles after sed"

grep "bin/svaba" Makefile.am
grep "bin/svaba" Makefile.in

echo ""

./configure CXXFLAGS=-fPIC --prefix=$PREFIX

echo "##################"
echo "# CONFIGURE DONE #"
echo "##################"

make

echo "#############"
echo "# MAKE DONE #"
echo "#############"

make install

echo "#####################"
echo "# MAKE INSTALL DONE #"
echo "#####################"

echo "#######################"
echo "# WHERE IS THE BINARY #"
echo "#######################"

echo ""

find . -name svaba | grep bin

echo "#######################"