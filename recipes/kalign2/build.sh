#!/bin/bash

set -e

# change makefile.in to honor the variables infered by configure
sed -i="" 's/=\ gcc/=\ @CC@/g' Makefile.in
sed -i="" 's/-O9\ \ -Wall/@CFLAGS@/g' Makefile.in

./configure
make

mkdir -p $PREFIX/bin
cp kalign $PREFIX/bin
