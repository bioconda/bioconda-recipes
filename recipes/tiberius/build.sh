#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -R $SRC_DIR/bin/* ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/tiberius.py
ln -s ${PREFIX}/bin/tiberius.py ${PREFIX}/bin/tiberius
sed -i.bak '1s|^|#!/usr/bin/env python3\n|' ${PREFIX}/bin/tiberius
rm -rf ${PREFIX}/bin/*.bak
