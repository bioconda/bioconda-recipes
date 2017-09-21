#!/bin/bash

mkdir -p $PREFIX/bin

chmod +x $SRC_DIR/rename
mv $SRC_DIR/rename $PREFIX/bin/rename
