#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX --disable-install-doc --enable-load-relative --with-openssl-dir=$PREFIX
make
make install
