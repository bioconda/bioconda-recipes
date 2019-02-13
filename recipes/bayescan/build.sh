#!/bin/bash

cd source
sed -i.bak "s/-static//g" Makefile
make
mkdir -p $PREFIX/bin
cp bayescan2 $PREFIX/bin
