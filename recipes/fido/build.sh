#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"
cd src/cpp
sed -i.bak 's/\tg++/\t$(CXX)/' makefile
make -j ${CPU_COUNT} BINPATH="${PREFIX}/bin"
