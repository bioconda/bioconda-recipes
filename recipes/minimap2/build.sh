#!/bin/bash

mkdir -p $PREFIX/bin

make
cp minimap2 $PREFIX/bin
