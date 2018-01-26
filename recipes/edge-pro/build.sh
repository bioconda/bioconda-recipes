#!/bin/bash
rm count
make
mkdir -p $PREFIX/bin
cp count edge.pl $PREFIX/bin/
