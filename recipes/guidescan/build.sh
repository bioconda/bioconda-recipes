#!/bin/bash

mkdir -p $PREFIX/bin
cd $SRC_DIR/guidescan-source_code

$PYTHON setup.py build # the docs mention this as a step
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
