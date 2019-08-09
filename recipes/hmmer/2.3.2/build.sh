#!/bin/sh

set -e -u -x

./configure --prefix=$PREFIX
make 
make install

