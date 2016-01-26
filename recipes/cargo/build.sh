#!/bin/bash -e

./configure --prefix=$PREFIX
make
make install
