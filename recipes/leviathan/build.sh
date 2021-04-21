#!/bin/bash

make -j"${CPU_COUNT}" BUILD_DIR=$PREFIX LREZ_LIBDIR=${PREFIX}/lib
make install BUILD_DIR=$PREFIX LREZ_LIBDIR=${PREFIX}/lib
