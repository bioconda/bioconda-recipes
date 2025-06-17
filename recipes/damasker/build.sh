#!/bin/bash

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT}"
make install DEST_DIR="${PREFIX}/bin"
