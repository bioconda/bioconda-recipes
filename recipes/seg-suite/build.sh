#!/usr/bin/env bash

set -xe

make -j"${CPU_COUNT}"

find . -type d -name "*.dSYM" -exec rm -rf {} +

make install prefix=$PREFIX
