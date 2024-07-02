#!/bin/bash

set -xe

make -j ${CPU_COUNT} install
cp bin/slclust $PREFIX/bin
