#!/bin/bash

cd src/
sed -i.bak -e 's/ -static//' Makefile

make CC=$CC CPP=$CXX LNK=$CXX

mkdir -p "$PREFIX"/bin
cp o/muscle5 "$PREFIX"/bin/muscle
