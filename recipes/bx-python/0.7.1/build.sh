#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

$PYTHON setup.py install
