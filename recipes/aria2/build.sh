#!/bin/bash

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

./configure --prefix=${PREFIX} --with-libz --with-libxml2 --with-libssh2 --with-libcares --with-sqlite3
make -j 2
make install
