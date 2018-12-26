#!/bin/bash

mkdir -p $PREFIX/bin
git submodule init
git submodule update
make
cp src/matlock $PREFIX/bin
