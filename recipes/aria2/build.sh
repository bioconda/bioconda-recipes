#!/bin/bash

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

if [ `uname` == Darwin ]; then
    # Needed for C++11 support.
    export MACOSX_DEPLOYMENT_TARGET=10.7
    # Needed to avoid the linker seeing the system-installed libxml2
    export LD_LIBRARY_PATH=${PREFIX}/lib
    ./configure --prefix=${PREFIX} --with-appletls --with-libz --with-libxml2 --with-libssh2 --with-libcares --with-sqlite3
else
    ./configure --prefix=${PREFIX} --with-openssl --with-libz --with-libxml2 --with-libssh2 --with-libcares --with-sqlite3
fi

make -j 2
make install
