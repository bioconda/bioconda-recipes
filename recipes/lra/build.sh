#!/bin/bash

mkdir -p $PREFIX/bin
export CPATH=${PREFIX}/include

make 
cp lra $PREFIX/bin
