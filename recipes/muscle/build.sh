#!/bin/bash

cd src/
sed -i.bak -e 's/ -static//' Makefile

make CXX=$CXX

mkdir -p "$PREFIX"/bin
cp "$(uname)"/muscle "$PREFIX"/bin/muscle
