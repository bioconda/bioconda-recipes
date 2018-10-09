#!/bin/sh

cd 20181005-161011

export C_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/ncurses
export LIBRARY_PATH=${PREFIX}/lib
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

make all -j

for i in *.x ; do
    install ${i} ${PREFIX}/bin
done
