#!/bin/bash

./bootstrap.sh
./configure --with-capnp=$PREFIX --with-gsl=$PREFIX --prefix=$PREFIX
make
make install
