#!/bin/bash
export CURRENTPATH=$pwd
cd /usr/local/include && ls
cd /usr/local/lib && ls
cd $CURRENTPATH
mkdir build
cd build
cmake .. -DINSTALL_BIN_PREFIX=$(pwd) -DINCLUDE_LIBRARY_PREFIX=/usr/local/include -DLIBRARY_LINK_PREFIX=/usr/local/lib/
make
make install
mkdir -p $PREFIX/bin
cp bolt $PREFIX/bin