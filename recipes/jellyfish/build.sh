#!/bin/bash

autoreconf -fi -Im4
./configure --prefix=$PREFIX
make
make install
