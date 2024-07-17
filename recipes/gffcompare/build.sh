#!/bin/bash

set -xe

export CXX="$CXX"
export LINKER="$CXX"

mkdir -p "$PREFIX"/bin/
make -j ${CPU_COUNT} release
cp gffcompare "$PREFIX"/bin/
cp trmap "$PREFIX"/bin/
