#!/bin/bash

./autogen.sh
./configure --prefix=${PREFIX} --with-jdk=${PREFIX}
make
make install
