#!/bin/bash

# use newer config.guess and config.sub that support osx-arm64
cp ${RECIPE_DIR}/config.* .

./configure --prefix=$PREFIX --without-x
make
make install

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
