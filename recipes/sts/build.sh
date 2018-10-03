#!/bin/bash

git submodule init
git submodule update

make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin
