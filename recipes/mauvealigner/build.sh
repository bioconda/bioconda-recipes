#!/bin/bash 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${CONDA_PREFIX}/lib/pkgconfig

#Disable static builds since these won't link to standard libraries
sed -i.bak 's/STATIC_FLAG="-static -Wl,--whole-archive -lpthread -Wl,--no-whole-archive"//' configure.ac
./autogen.sh
./configure --prefix=$PREFIX 
make
find src -maxdepth 1 -perm +111 -exec strip {} \;
make install
