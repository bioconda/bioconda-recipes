#!/bin/bash

# cmake's "find GSL macro" can barf when conda
# envs are involved, so we use GSL_ROOT_DIR to 
# fix that:
GSL_ROOT_DIR=$PREFIX $PYTHON -m pip install --no-deps --ignore-installed -vv .
