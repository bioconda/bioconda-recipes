#!/bin/bash

mkdir -p "${PREFIX}/bin"

make CC="${CC}" CXX="${CXX}" FLAGS="-O3" HTSSRC="systemwide" -j"${CPU_COUNT}"

install -v -m 755 ./metaDMG-cpp ./misc/compressbam ./misc/extract_reads "${PREFIX}/bin"
