#!/bin/sh
set -e

./bootstrap
./configure --prefix="${PREFIX}"
make
make install
