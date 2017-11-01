#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX}
make
mv src/parsnp ${PREFIX}/bin/

