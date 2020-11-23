#!/bin/bash

mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/lib/
mkdir -p $PREFIX/include/

cp bin/* $PREFIX/bin/
cp lib/* $PREFIX/lib/
cp -R include/* $PREFIX/include/
cp $RECIPE_DIR/EvoFoldV2.sh $PREFIX/bin

chmod +x $PREFIX/bin/*


