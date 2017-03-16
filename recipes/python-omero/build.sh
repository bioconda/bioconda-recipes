#!/bin/bash

cd ./lib/python
cp $RECIPE_DIR/setup.py .
$PYTHON setup.py install
