#!/bin/bash

chmod +x *
cp -r . $PREFIX/

python $RECIPE_DIR/fix_acd_path.py $PREFIX/bin
