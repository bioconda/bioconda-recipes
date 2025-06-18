#!/bin/bash

mkdir -p "${PREFIX}/bin"

make CC="${CC}" -j"${CPU_COUNT}"
make install
