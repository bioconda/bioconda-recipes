#!/bin/bash

./configure --prefix=${PREFIX} --with-libdeflate=${PREFIX}
make
make install
