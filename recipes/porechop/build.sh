#!/bin/bash

rm -rf porechop/include/seqan
cp -r $PREFIX/include/seqan porechop/include
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON -m unittest
