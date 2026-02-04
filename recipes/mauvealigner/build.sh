#!/bin/bash 

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${PREFIX}/lib/pkgconfig"

./autogen.sh
./configure --prefix=$PREFIX 
make
find src -maxdepth 1 -perm +111 -exec strip {} \;
make install
