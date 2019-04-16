#!/bin/bash

cd ./lib/python
cp $RECIPE_DIR/setup.py .
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
rm setup.py

cd ../..
cp bin/omero $PREFIX/bin/
