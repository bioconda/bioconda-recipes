#!/bin/bash

set -xe

export CXX="$CXX"
export LINKER="$CXX"

mkdir -p "$PREFIX"/bin/
make release
cp gffcompare "$PREFIX"/bin/
cp trmap "$PREFIX"/bin/