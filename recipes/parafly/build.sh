#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make -j ${CPU_COUNT} install
cp $PREFIX/bin/ParaFly $PREFIX
