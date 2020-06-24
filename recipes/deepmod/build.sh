#!/bin/bash

$PYTHON setup.py install


#ls $PREFIX
#ls $PREFIX/bin/*.py
#ls $SP_DIR

mkdir $SP_DIR/DeepMod
cp -r train_deepmod $SP_DIR/DeepMod/

#ls $SP_DIR/DeepMod/train_deepmod


