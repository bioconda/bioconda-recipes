#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC="${CXX}" install
cp bin/slclust $PREFIX/bin
