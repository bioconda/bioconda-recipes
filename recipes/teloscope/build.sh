#!/bin/bash
set -xe

export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -g -Wall -O3 -I$PREFIX/include -I$SRC_DIR/include -I$SRC_DIR/include/zlib -std=gnu++17 -lstdc++"

make CXX="$CXX" -j"${CPU_COUNT}"
mkdir -p $PREFIX/bin
install -v -m 0755 build/bin/teloscope $PREFIX/bin

mkdir -p $PREFIX/bin/scripts
install -v -m 0644 scripts/teloscope_report.py $PREFIX/bin/scripts/teloscope_report.py