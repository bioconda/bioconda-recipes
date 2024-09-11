#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make
cp sam2pairwise $PREFIX/bin
