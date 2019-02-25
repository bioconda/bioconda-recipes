#!/bin/bash

mkdir -p $PREFIX/bin

cp -r $RECIPE_DIR/taxsbp $PREFIX/bin
cp $RECIPE_DIR/TaxSBP.py $PREFIX/bin