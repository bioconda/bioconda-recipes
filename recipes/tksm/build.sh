#!/bin/bash
INSTALL_PREFIX="${PREFIX}" make -j16
mkdir -p ${PREFIX}/bin
./install.sh
