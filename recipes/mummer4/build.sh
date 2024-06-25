#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
