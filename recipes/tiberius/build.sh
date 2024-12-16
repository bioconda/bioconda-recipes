#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -rf $SRC_DIR/bin/dev/convert_weights.py ${PREFIX}/bin
cp -Rf $SRC_DIR/bin/* ${PREFIX}/bin
chmod +x ${PREFIX}/bin/tiberius.py
chmod +x ${PREFIX}/bin/convert_weights.py
ln -sf ${PREFIX}/bin/tiberius.py ${PREFIX}/bin/tiberius
