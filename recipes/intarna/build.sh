#!/bin/sh
./configure --prefix=$PREFIX --with-RNA=$PREFIX && \
make && \
make install
