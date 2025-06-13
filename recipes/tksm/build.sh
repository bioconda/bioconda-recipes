#!/bin/bash
INSTALL_PREFIX="${PREFIX}" make -j${CPU_COUNT}
mkdir -p ${PREFIX}/bin
./install.sh
