#!/bin/bash
cp $RECIPE_DIR/setup.py $SRC_DIR/setup.py
$PYTHON setup.py install
