#!/bin/bash

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DINSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=11 \
    .
make
make install
