#!/bin/bash
target=$PREFIX/lib/mirdeep2
mkdir -p $target
mkdir -p $PREFIX/bin
cp *pl $target
ln -s $target/miRDeep2.pl $PREFIX/bin/miRDeep2.pl
