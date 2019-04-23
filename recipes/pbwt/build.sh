#!/bin/bash

#cd pbwt-64c4ffa7880db5f85b53ccbd7e530ec4b95ea4ba
ls
sed -i.bak 's/$(HTSLIB)/-lhts/' Makefile
sed -i.bak 's/\"zlib.h\"/\<zlib.h\>/' pbwtPaint.c utils.h
make
cp pbwt $PREFIX/bin

