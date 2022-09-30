#!/bin/bash
set -eux
./configure --prefix=$PREFIX
make
make install
