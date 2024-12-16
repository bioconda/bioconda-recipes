#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i.bak '1s|^|#!/usr/bin/env python3\n|' bin/dev/convert_weights.py
rm -rf bin/dev/*.bak

cp -rf $SRC_DIR/bin/dev/convert_weights.py "${PREFIX}/bin"
cp -Rf $SRC_DIR/bin/* "${PREFIX}/bin"
cp -rf $SRC_DIR/bin/tiberius.py "${PREFIX}/bin/tiberius"
chmod 0755 ${PREFIX}/bin/tiberius.py
chmod 0755 ${PREFIX}/bin/tiberius
chmod 0755 ${PREFIX}/bin/convert_weights.py
