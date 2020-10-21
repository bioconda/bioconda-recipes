#!/bin/bash
mkdir -p $PREFIX/bin
cd src
#sed -i.bak 's/-lrt//' Makefile
sed -i.bak 's/CXX  = gcc//' Makefile

make clean
make CXX=$CC
make CXX=$CC gmer_counter
make CXX=$CC gmer_caller

cp glistcompare glistmaker glistquery gmer_counter gmer_caller $PREFIX/bin
