#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin
cp ancestral_reconstruction.py $PREFIX/bin
cp timetree_inference.py $PREFIX/bin
cp temporal_signal.py $PREFIX/bin
