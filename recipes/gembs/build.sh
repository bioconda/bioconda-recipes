#!/bin/bash

#instead of installing software from submodules, let them be dependencies

#install locally included non-python code
make --directory=tools conda
cp tools/bin/{gemBS_cat,readNameClean} $PREFIX/bin

$PYTHON setup.py install

