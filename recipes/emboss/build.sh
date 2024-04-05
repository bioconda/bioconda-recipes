#!/bin/bash
./configure --prefix=$PREFIX --without-x
make
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
