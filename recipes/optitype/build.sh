#!/bin/bash
mkdir -p $PREFIX/bin
cp -r data $PREFIX/bin
cp *.py $PREFIX/bin
cp $RECIPE_DIR/config.ini $PREFIX/bin
chmod +x $PREFIX/bin/*.py
