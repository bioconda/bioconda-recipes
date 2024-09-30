#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -R $SRC_DIR/bin/* ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/tiberius.py
ln -s ${PREFIX}/bin/tiberius.py ${PREFIX}/bin/tiberius
sed -i '1s|^|#!/usr/bin/env python3\n|' ${PREFIX}/bin/tiberius

#Temporary: until the specific branch of learnMSA compatible with Tiberius is merged
#Adding learnMSA
git clone https://github.com/Gaius-Augustus/learnMSA
cd learnMSA
git checkout parallel
pip install .
cd ..
