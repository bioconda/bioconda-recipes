#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX}
make 
make install
sed -i.bak '1i#!/usr/bin/env python\n' ${PREFIX}/bin/Parsnp.py
mv ${PREFIX}/bin/Parsnp.py ${PREFIX}/bin/parsnp
