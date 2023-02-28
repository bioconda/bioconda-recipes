#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
ls
sed -i.bak 's/$(HTSLIB)/-lhts/' Makefile
make
cp pbwt $PREFIX/bin

