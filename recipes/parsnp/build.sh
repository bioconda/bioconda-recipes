#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX}
make
sed -i '1i#!/usr/bin/env python\n/' Parsnp.py
mv Parsnp.py parsnp
/usr/bin/install parsnp ${PREFIX}/bin/
make install
