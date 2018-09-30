#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
gcc -v

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
