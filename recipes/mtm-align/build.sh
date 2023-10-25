#!/bin/bash
set -ex

tar xjf mTM-align.tar.bz2
cd mTM-align/src/
make

mkdir -p $PREFIX/bin
mv mTM-align $PREFIX/bin/mtm-align
