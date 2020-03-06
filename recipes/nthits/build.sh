#!/bin/bash
./autogen.sh
./configure --prefix=$PREFIX
make
make install
