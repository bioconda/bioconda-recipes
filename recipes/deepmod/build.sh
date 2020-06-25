#!/bin/bash

$PYTHON -m pip install . --no-deps --ignore-installed -vv

mkdir $SP_DIR/DeepMod
cp -r train_deepmod $SP_DIR/DeepMod/
