#!/bin/bash

./bootstrap.sh
./configure --prefix=${PREFIX}
make
make install
