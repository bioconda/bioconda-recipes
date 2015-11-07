#!/bin/sh

./configure --prefix=$PREFIX
make
make install

# Run tests
./testit.sh

