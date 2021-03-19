#!/bin/bash

mkdir -p $PREFIX/bin
cp -r $SRC_DIR/* $PREFIX
cp $RECIPE_DIR/metamorpheus $PREFIX/metamorpheus
chmod +x $PREFIX/metamorpheus
