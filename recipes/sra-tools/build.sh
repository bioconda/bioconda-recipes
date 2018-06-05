#!/bin/bash

./configure --prefix=$PREFIX \ --build-prefix=$PREFIX/share/ncbi/ --with-ngs-sdk-prefix=$PREFIX
make
make install
make tests
