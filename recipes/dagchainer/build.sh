#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin
make -j"${CPU_COUNT}" CC=${CXX}

