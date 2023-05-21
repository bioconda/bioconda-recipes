#!/bin/bash
$PYTHON -m pip install . --ignore-installed --no-deps -vv
cd probeit/setcover
make CXXFLAGS="${CXXFLAGS} -I. -O3 -std=c++14" -j $CPU_COUNT
install -d "${PREFIX}/bin"
install setcover "${PREFIX}/bin/"
cd ../..
