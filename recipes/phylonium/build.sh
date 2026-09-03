#!/bin/bash
set -euxo pipefail

autoreconf -fi -Im4
./configure --prefix="${PREFIX}" --disable-dependency-tracking
make -j"${CPU_COUNT:-1}"
make install
