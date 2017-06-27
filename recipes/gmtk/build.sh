#!/bin/sh

./configure --with-logp --prefix=$PREFIX
make
make install
