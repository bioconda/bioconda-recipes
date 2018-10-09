#!/bin/bash
autoreconf -fi
./configure --prefix=$PREFIX --without-guile --without-lua --with-libxml
make
make install

