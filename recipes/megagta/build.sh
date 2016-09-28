#!/bin/bash
git submodule update --init --recursive
./make.sh
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
