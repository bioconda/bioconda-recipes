#!/bin/bash

mkdir -p "$PREFIX/bin"

make -C src/ all CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 bin/* "$PREFIX/bin"
