#!/usr/bin/env sh

export C_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/ncurses
export LIBRARY_PATH=${PREFIX}/lib
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

make all -j 1  ## do not use >1 make threads!

for i in *.x ; do
    install ${i} ${PREFIX}/bin
done
