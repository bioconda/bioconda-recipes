#!/bin/bash

export CPLUS_INCLUDE_PATH=$PREFIX/include
make

mkdir -p $PREFIX/bin
cp gfold $PREFIX/bin
