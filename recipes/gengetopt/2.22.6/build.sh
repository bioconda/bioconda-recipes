#!/bin/sh

autoreconf -vif && \
./configure --prefix=$PREFIX && \
make && \
make install
