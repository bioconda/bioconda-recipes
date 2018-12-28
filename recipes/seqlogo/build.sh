#!/bin/bash
python3 -m pip install . --no-deps --ignore-installed -vv
chmod -R 777 $PREFIX
chmod -R 777 $RECIPE_DIR
chmod -R 777 $SP_DIR
chmod -R 777 $SRC_DIR
