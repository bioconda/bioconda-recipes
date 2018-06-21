#!/bin/bash

mkdir -p $PREFIX/bin

# sed on OSX has a different -i option
sed "1d" Makefile > Makefile
export LIBRARY_PATH="$PREFIX/lib"
export C_INCLUDE_PATH="$PREFIX/include"
make
mv trimadap-mt  $PREFIX/bin
