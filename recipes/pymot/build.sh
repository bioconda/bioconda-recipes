#!/bin/bash

cp $RECIPE_DIR/setup.py .
$PYTHON -m pip install . --ignore-installed --no-deps -vv
