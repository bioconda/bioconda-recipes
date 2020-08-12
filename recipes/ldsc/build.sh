#!/bin/bash
cp $RECIPE_DIR/setup.py ./
$PYTHON -m pip install . --no-deps --ignore-installed -vv
