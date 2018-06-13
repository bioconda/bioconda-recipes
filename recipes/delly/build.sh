#!/bin/sh


# build delly
make all
mkdir -p $PREFIX/bin
cp src/delly src/dpe $PREFIX/bin
