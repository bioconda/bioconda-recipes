#!/bin/bash

cd samtools
CURSES_LIB="-ltinfow -lncursesw"
./configure --prefix=$PREFIX --with-htslib=system CURSES_LIB="$CURSES_LIB"
make all
cd ../src
ln -s ../samtools samtools
sed -i.bak 's/c++11/c++17/g' Makefile
sed -i.bak 's/g++/ g++ -Wl,--as-needed/g' Makefile
sed -i.bak 's,(HTSDIR)/libhts.a,(PREFIX)/lib/libhts.a,g' Makefile
sed -i.bak 's,-lMathCore,-lMathCore -ldl -ldeflate,g' Makefile
export CPLUS_INCLUDE_PATH=$PREFIX/include
make
cp cnvnator $PREFIX/bin/cnvnator
