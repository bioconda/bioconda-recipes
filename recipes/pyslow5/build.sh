#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
