#!/bin/bash

mkdir -p "${PREFIX}/bin"

rm -f *.bak

make -j"${CPU_COUNT}"

install -v -m 0755 LCA "${PREFIX}/bin"
