#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -rf $SRC_DIR/bin/dev/* ${PREFIX}/bin
cp -Rf $SRC_DIR/bin/* ${PREFIX}/bin
chmod +x ${PREFIX}/bin/tiberius.py
ln -sf ${PREFIX}/bin/tiberius.py ${PREFIX}/bin/tiberius
