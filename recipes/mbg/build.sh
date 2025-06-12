#!/usr/bin/env bash

set -xe

cd $SRC_DIR
make -j ${CPU_COUNT} bin/MBG
mkdir -p $PREFIX/bin
cp bin/MBG $PREFIX/bin
