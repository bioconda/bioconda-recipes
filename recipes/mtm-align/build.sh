#!/bin/bash
set -ex

cd src/
make

mkdir -p $PREFIX/bin
mv mTM-align $PREFIX/bin/mtm-align
