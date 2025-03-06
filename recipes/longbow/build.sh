#!/bin/bash

mkdir -p $PREFIX/bin;
cp -r $SRC_DIR/src/longbow/* $PREFIX/bin;
chmod -R +x $PREFIX/bin;
