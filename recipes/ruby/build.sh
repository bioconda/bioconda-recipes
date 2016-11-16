#!/bin/bash

./configure \
        --prefix=$PREFIX \
        --enable-load-relative \
        --disable-install-doc \
        --enable-shared \
        --enable-rpath \
        --with-jemalloc \
        --with-opt-dir=$PREFIX \
        --with-libyaml-dir=$PREFIX \
        --with-openssl-dir=$PREFIX \
        --with-readline-dir=$PREFIX \
        --with-zlib-dir=$PREFIX
        # --with-static-linked-ext \

make
make install

