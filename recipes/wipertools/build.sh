#!/bin/sh

# mkdir -p $PREFIX/lib/python$PY_VER/site-packages/tests/testdata
# cp -r tests/testdata/* $PREFIX/lib/python$PY_VER/site-packages/tests/testdata/
mkdir -p $PREFIX/lib/python$PY_VER/site-packages/
cp versions.json $PREFIX/lib/python$PY_VER/site-packages/

$PYTHON setup.py install --single-version-externally-managed --record=$RECIPE_DIR/record.txt
