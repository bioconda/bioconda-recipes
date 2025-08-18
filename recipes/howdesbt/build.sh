#!/bin/bash

mkdir -p "${PREFIX}/bin"

make CXX="${CXX}" -f Makefile_full -j"${CPU_COUNT}"

install -v -m 755 howdesbt "${PREFIX}/bin"
