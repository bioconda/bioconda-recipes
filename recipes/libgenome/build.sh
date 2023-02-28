#!/bin/bash

cd trunk
# This redefines abs(), which shouldn't happen
sed -i.bak "8,10d" libGenome/gnDefs.cpp
./autogen.sh
./configure --prefix=$PREFIX
make
make install
