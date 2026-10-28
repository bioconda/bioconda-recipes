#!/bin/bash

mkdir -p $PREFIX/bin
cp bin/PylProtPredictor $PREFIX/bin/pylprotpredictor

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

