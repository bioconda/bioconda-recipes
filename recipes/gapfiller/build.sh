#!/bin/bash

autoreconf -fi
./configure --with-boost="${PREFIX}" --prefix="${PREFIX}"
make
make install
