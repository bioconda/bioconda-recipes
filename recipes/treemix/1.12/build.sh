#!/bin/bash

./configure --with-boost=${PREFIX} CPPFLAGS=-I${PREFIX} --prefix=$PREFIX
make
make install
