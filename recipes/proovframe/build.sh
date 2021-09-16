#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
chmod +x bin/*

cp -r bin $PREFIX/
cp -r lib/Fasta $PREFIX/lib/