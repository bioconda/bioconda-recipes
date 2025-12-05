#!/bin/bash

mkdir -p $PREFIX/bin

make CC="${CC} -fcommon" -j"${CPU_COUNT}"

install -v -m 0755 starcode "$PREFIX/bin"
