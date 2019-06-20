#!/bin/bash
mkdir -p $PREFIX/bin
cd src
sed -i.bak 's/-lrt//' Makefile

make

cp glistcompare glistmaker glistquery $PREFIX/bin
