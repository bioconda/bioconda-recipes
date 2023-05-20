#!/bin/bash
set -x
autoreconf -i
ls -l
./configure --help
./configure
make
make install PREFIX=$PREFIX
