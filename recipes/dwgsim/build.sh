#!/bin/bash

make CC=$CC LIBCURSES=-lncurses 

mkdir -p $PREFIX/bin

cp dwgsim $PREFIX/bin
cp dwgsim_eval $PREFIX/bin
