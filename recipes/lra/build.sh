#!/bin/bash

mkdir -p $PREFIX/bin
export CPATH=${PREFIX}/include

make CC="${CC}"
cp lra $PREFIX/bin
