#!/bin/bash

export CFLAGS="${CFLAGS} -fcommon"

./configure --prefix=$PREFIX --without-x
make
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
chmod +x $PREFIX/bin/*
