#!/bin/bash

mkdir -p $PREFIX/bin
cp -r $SRC_DIR/piawka $SRC_DIR/include $PREFIX/bin/ 
chmod +x $PREFIX/bin/piawka

