#!/bin/bash

cd source
make
mkdir -p $PREFIX/bin
cp bayescan2 $PREFIX/bin
