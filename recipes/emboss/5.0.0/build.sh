#!/bin/bash

cp -r . $PREFIX/

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
chmod +x $PREFIX/bin/*
