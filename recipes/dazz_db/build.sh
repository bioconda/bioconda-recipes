#!/bin/bash

mkdir -p $PREFIX/bin
make
cp $(find . -maxdepth 1 -type f -perm /u=x)  $PREFIX/bin

