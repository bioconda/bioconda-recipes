#!/bin/bash

mkdir -p $PREFIX/bin
cp -r * $PREFIX
pip install tools/suffix_tree-2.1.tar.gz
ln -s ../rop.sh $PREFIX/bin/rop
