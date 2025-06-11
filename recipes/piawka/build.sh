#!/bin/bash

mkdir -p $PREFIX/bin
cp $SRC_DIR/scripts/* $PREFIX/bin/ 
chmod +x $PREFIX/bin/*

