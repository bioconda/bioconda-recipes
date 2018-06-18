#!/usr/bin/env bash

sh autogen.sh
./configure --prefix=$PREFIX
make
make install
