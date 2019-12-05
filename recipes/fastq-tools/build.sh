#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX
make install
