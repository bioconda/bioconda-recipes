#!/usr/bin/env bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin
cp $SRC_DIR/weave $PREFIX/bin
cp $SRC_DIR/clean $PREFIX/bin