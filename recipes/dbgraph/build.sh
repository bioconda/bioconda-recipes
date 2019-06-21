#!/bin/bash

mkdir -p $PREFIX/bin

cd $RECIPE_DIR/Graph2Pro
make clean
make
#make check

cp $RECIPE_DIR/Graph2Pro/DBGraph2Pro $PREFIX/bin/DBGraph2Pro
cp $RECIPE_DIR/Graph2Pro/DBGraphPep2Pro $PREFIX/bin/DBGraphPep2Pro
