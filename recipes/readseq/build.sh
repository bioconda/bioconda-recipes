#!/bin/bash

mkdir -p $PREFIX/bin

cp -R $SRC_DIR/${PKG_NAME}.jar $PREFIX/bin 
chmod +x $PREFIX/bin/${PKG_NAME}.jar




