#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
cp -f migmap-$PKG_VERSION.jar $PREFIX/share/migmap.jar
cp -f $RECIPE_DIR/migmap.sh $PREFIX/bin/migmap
