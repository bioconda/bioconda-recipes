#!/bin/bash
autoreconf -fi
./configure --exec-prefix=$PREFIX
make
make install
