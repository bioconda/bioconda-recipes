#!/bin/bash

mkdir -p $PREFIX/bin;
cp $SRC_DIR/src/longbow/longbow.py $PREFIX/bin;

mkdir -p $PREFIX/bin/module;
cp $SRC_DIR/src/longbow/module/* $PREFIX/bin/module;

mkdir -p $PREFIX/bin/model;
cp $SRC_DIR/src/longbow/model/* $PREFIX/bin/model;
