#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX}
make 
make install
mv bin/parsnp ${PREFIX}/bin/ 
