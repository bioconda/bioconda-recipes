#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/metameta/
cp -r * $PREFIX/opt/metameta/
ln -s $PREFIX/opt/metameta/metameta $PREFIX/bin/ 
