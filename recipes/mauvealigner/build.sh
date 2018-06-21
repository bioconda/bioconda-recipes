#!/bin/bash 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${CONDA_PREFIX}/lib/pkgconfig

./autogen.sh
./configure --prefix=$PREFIX 
make
find src -maxdepth 1 -perm +111 -exec strip {} \;
make install


