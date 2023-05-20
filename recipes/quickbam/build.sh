#!/bin/bash
set -x
./configure --prefix=$PREFIX
make
make install
