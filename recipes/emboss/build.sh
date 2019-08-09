#!/bin/bash

# Remove some .la confusing libtool
rm $PREFIX/lib/*.la

./configure --prefix=$PREFIX --without-x
make
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
chmod +x $PREFIX/bin/*
