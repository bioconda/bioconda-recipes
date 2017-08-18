#!/usr/bin/env bash

mkdir $PREFIX/obj
#mkdir $PREFIX/src

make clean
make prefix=$PREFIX
