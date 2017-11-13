#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export CPP_INCLUDE_PATH=$PREFIX/include
export CPATH=${PREFIX}/include

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
