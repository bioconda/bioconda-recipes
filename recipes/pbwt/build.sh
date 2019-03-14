#!/bin/bash

cd pbwt*
sed -i.bak 's/$(HTSLIB)/-lhts/' Makefile
make
cp pbwt $PREFIX/bin

