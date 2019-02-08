#!/usr/bin/env bash

$PYTHON setup.py install
mkdir -p $PREFIX/bin
cp -rp src/cbImportSeurat $PREFIX/bin
