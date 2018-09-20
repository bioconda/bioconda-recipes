#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS=$CPPFLAGS
export LDFLAGS="-L$PREFIX/lib"

./bootstrap.sh
./configure --prefix $PREFIX --with-boost $PREFIX

echo "TORSTEN: PREFIX=[$PREFIX]"

sed -i.bak -e "s|/usr/local|$PREFIX|g" Makefile

cat Makefile

make install
