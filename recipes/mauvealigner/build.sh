#!/bin/bash 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${CONDA_PREFIX}/lib/pkgconfig

./autogen.sh
./configure --prefix=$PREFIX 
sed -i.bak -e 's/ mauveStatic$(EXEEXT)//' -e 's/\tprogressiveMauveStatic$(EXEEXT)/\t/' src/Makefile
make
find src -maxdepth 1 -perm +111 -exec strip {} \;
make install
