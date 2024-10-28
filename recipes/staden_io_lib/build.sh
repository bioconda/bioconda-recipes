#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

autoreconf -if
./configure --prefix=${PREFIX} --with-libdeflate=${PREFIX}
make -j"${CPU_COUNT}"
make install

cp -f io_lib_config.h ${PREFIX}/include/io_lib/
