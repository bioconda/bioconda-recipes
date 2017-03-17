#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX
make -j VERBOSE=1
make install

