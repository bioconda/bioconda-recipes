#!/bin/bash

cd src

autoreconf -fi
./configure --prefix="${PREFIX}"
make all mpis
make install
