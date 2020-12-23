#!/bin/bash

cd $PREFIX/$PKG_NAME
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/
