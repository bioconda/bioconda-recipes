#!/bin/bash
set -eu
./configure --prefix=${PREFIX}
make install
