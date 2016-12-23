#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
chmod a+x $SRC_DIR/taco
cp $SRC_DIR/taco $PREFIX/bin/
