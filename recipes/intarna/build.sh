#!/bin/sh
./configure --prefix=$PREFIX --with-RNA=$PREFIX --with-boost=$PREFIX --disable-multithreading && \
make && \
make install
