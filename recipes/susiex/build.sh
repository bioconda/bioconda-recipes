#!/bin/bash

set -eux -o pipefail

# Upstream hard-codes g++, so patch the Makefile to use Conda's compiler and flags.
sed -i.bak \
  -e 's|g++ main.cpp data.o model.o -O3|$(CXX) $(CXXFLAGS) $(CPPFLAGS) main.cpp data.o model.o $(LDFLAGS) -O3|' \
  -e 's|g++ -c |$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c |' \
  src/makefile

make -C src -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -m 0755 bin/SuSiEx "${PREFIX}/bin/"
