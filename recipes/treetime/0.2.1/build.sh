#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin
cp *.py $PREFIX/bin