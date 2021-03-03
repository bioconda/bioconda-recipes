#!/bin/bash

mkdir -p $PREFIX/bin
cp -r * $PREFIX
cp $RECIPE_DIR/metamorpheus $PREFIX/bin/metamorpheus
chmod +x $PREFIX/bin/metamorpheus
