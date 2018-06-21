#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
mkdir -p $PREFIX/bin
chmod a+x *.py
sed -i.bak "1i#!/usr/bin/env python" ancestral_reconstruction.py
sed -i.bak "1i#!/usr/bin/env python" timetree_inference.py
cp ancestral_reconstruction.py timetree_inference.py $PREFIX/bin
