#!/bin/bash

export CPPFLAGS="-std=c++11"
./configure --prefix=$PREFIX
make
make install
