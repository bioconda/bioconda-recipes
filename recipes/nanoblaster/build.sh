#!/bin/bash

mkdir -p $PREFIX/bin
cd nano_src
make
cp nanoblaster $PREFIX/bin

