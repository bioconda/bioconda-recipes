#!/bin/bash

set -xe

scripts/install-hts.sh
make -j ${CPU_COUNT} CC=$CC
mkdir -p $PREFIX/bin
cp minimod $PREFIX/bin/minimod
