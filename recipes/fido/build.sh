#!/bin/bash

mkdir -p "${PREFIX}/bin"
cd src/cpp
sed -i.bak 's/\tg++/\t$(CXX)/' makefile
make BINPATH="${PREFIX}/bin"
