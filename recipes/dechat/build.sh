#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin

if [ "$(uname)" == "Darwin" ]; then
    cp -f ${SRC_DIR}/bin/dechat ${PREFIX}/bin/
else
    mkdir build && cd build
    cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" -DKSIZE_LIST="32 64 96 128 160 192" ..
    make -j"${CPU_COUNT}"
    chmod 755 ${SRC_DIR}/bin/dechat
    cp -f ${SRC_DIR}/bin/dechat ${PREFIX}/bin/
fi
