#!/bin/bash

make

mkdir -p $PREFIX/bin
cp velvetg $PREFIX/bin
cp velveth $PREFIX/bin
cp *.pl $PREFIX/bin