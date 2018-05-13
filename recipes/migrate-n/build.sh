#!/bin/bash


cd src

./configure
sed -i 's/#include <xlocale.h>//' data.c
make

mkdir -p $PREFIX/bin

cp migrate-n $PREFIX/bin

