#!/bin/sh


# build alfred
make all
mkdir -p $PREFIX/bin
cp src/alfred $PREFIX/bin
