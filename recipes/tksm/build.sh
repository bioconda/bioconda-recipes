#!/bin/bash

INSTALL_PREFIX="${PREFIX}" make -j8
mkdir -p ${PREFIX}/bin
./install.sh
