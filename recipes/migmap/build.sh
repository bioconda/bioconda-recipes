#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
cp -f migmap-0.9.7.jar $PREFIX/share/
cp -f $RECIPE_DIR/migmap.sh $PREFIX/bin/migmap
