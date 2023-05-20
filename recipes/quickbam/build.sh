#!/bin/bash
set -e
autoreconf -i
./configure --help
./configure
make
make install PREFIX=$PREFIX
