#!/bin/bash

mkdir -p "${PREFIX}/bin"

make CC="${CC}" -j"${CPU_COUNT}"
make install DEST_DIR="${PREFIX}/bin"
