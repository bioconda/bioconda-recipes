#!/bin/bash
./configure --prefix=$PREFIX --disable-install-doc --enable-load-relative --with-openssl-dir=$PREFIX
make
make install
