#!/bin/bash

autoreconf -ifv
./configure --prefix=${PREFIX}
make -j4
make install
