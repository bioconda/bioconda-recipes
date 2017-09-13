#!/bin/bash

./configure --prefix=$PREFIX --without-guile --without-lua --with-libxml
make
make install

