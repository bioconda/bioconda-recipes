#!/bin/bash

cd trunk
./autogen.sh
./configure --prefix=$PREFIX
make
make install
