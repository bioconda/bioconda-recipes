#!/bin/bash

## https://github.com/bioconda/bioconda-recipes/pull/1294/files


sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile
 
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make 
mkdir -p $PREFIX/bin
cp glia $PREFIX/bin


