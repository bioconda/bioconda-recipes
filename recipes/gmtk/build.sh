#!/bin/sh

./configure --with-logp=table --prefix=$PREFIX
make
make install
