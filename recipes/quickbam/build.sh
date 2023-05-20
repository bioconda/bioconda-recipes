#!/bin/bash
set -e
autoreconf -i
ls -l
./configure --help
./configure
make
make install PREFIX=$PREFIX
