#!/bin/bash
set -eu
mkdir -p $PREFIX/bin
chmod +x $SRC_DIR/taco_run
cp $SRC_DIR/taco_run $PREFIX/bin/taco_run
