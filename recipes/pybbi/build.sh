#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib
sed -i.bak "89,92d" setup.py
$PYTHON -m pip install . --no-deps --ignore-installed -vv
