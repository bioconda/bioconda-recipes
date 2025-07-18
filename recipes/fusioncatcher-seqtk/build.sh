#!/bin/bash

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT}"

install -v -m 0755 seqtk "${PREFIX}/bin"
