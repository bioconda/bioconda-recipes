#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make -j ${CPU_COUNT} LIBS+=-lhts
make install
