#!/bin/sh

./configure --prefix=$PREFIX && \
make && \
make install
