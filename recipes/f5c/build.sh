#!/bin/bash
scripts/install-hts.sh
./configure
make
mkdir -p $PREFIX/bin
cp f5c $PREFIX/bin/f5c
