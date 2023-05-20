#!/bin/bash
set -x
./configure --help
./configure
make
make install PREFIX=$PREFIX
