#!/bin/bash
set -eu
./configure --prefix=${PREFIX}

#debug
cat config.log

make install
