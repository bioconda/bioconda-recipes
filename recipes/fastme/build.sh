#!/bin/bash

set -xe

autoreconf -ifv
./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
