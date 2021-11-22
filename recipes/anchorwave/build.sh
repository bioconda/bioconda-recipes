#!/bin/bash

set -eux

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ./
make -j"${CPU_COUNT}"
make install
