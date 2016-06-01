#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include

./configure --prefix=$PREFIX
make && make install
