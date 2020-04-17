#!/bin/bash
mkdir -p $PREFIX/bin
cd src
sed -i.bak 's/-lrt//' Makefile

make CC=$CC
make
make gmer_counter
make gmer_caller

cp glistcompare glistmaker glistquery gmer_counter gmer_caller $PREFIX/bin
