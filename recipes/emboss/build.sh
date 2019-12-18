#!/bin/bash

./configure --prefix=$PREFIX --without-x
sed -i.bak 's/\t$(bindir)\/embossupdate//g' Makefile
make
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
chmod +x $PREFIX/bin/*
