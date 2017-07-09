#!/bin/bash

make

mkdir -p $PREFIX/bin
cp src/ALE $PREFIX/bin
cp src/synthReadGen $PREFIX/bin
cp src/*.py $PREFIX/bin