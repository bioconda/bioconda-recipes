#!/bin/bash
set -x
autoreconf
ls -l
./configure --help
./configure
make
make install PREFIX=$PREFIX
