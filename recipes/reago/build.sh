#!/bin/bash
cp $RECIPE_DIR/setup.py $SRC_DIR/setup.py
cp $RECIPE_DIR/MANIFEST.in $SRC_DIR/MANIFEST.in
$PYTHON setup.py install
