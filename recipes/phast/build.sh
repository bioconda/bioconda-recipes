#!/bin/sh

mkdir -p $PREFIX/bin

cd src

# PHAST needs a path to Clapack libraries to compile
make CC=$CC CLAPACKPATH=$ORIGIN

# PHAST builds multiple binaries
cd ..
chmod +x bin/*
mv bin/* $PREFIX/bin
