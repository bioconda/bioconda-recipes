#!/bin/bash

mkdir -p $PREFIX/bin
cp $RECIPE_DIR/bin/* $PREFIX/bin

mkdir -p $PREFIX/lib
cp $RECIPE_DIR/lib/* $PREFIX/lib

mkdir -p $PREFIX/doc
cp $RECIPE_DIR/doc/* $PREFIX/doc

export PATH=$PATH:${PREFIX}/bin
