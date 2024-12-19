#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make -j ${CPU_COUNT} AM_MAKEFLAGS=-e
install -d "${PREFIX}/bin"
install src/variant "${PREFIX}/bin/"
