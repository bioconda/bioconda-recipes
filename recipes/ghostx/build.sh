#!/usr/bin/env bash

set -xe

cd ./src/

make -j"${CPU_COUNT}"

mkdir -p $PREFIX/bin
install -m 755 ghostx $PREFIX/bin
