#!/bin/bash

mkdir -p $PREFIX/bin;
cp -r $SRC_DIR/artex/* $PREFIX/bin;
chmod +x $PREFIX/bin;
