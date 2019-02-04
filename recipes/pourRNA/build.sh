#!/bin/sh

autoreconf -i
./configure
make
make install
