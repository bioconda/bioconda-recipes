#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX}
make
sed -i.bak '1i#!/usr/bin/env python\n' Parsnp.py
sed -i.bak 's/sys\.stderr\.write(\ BOLDME/sys\.stdout\.write(\ BOLDME/' Parsnp.py
head Parsnp.py 
mv Parsnp.py parsnp
/usr/bin/install parsnp ${PREFIX}/bin/
