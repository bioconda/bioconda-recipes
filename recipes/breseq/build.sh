#!/bin/bash
set -eux
./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
