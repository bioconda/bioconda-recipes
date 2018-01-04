#!/bin/bash

libtoolize
aclocal
autoreconf -i -f
./configure
make
