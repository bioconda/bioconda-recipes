#!/bin/bash
set -eu -o pipefail

export LIBS="-lm ${PREFIX}/lib/libz.a"

CXXFLAGS="${CXXFLAGS} -fPIC"

./configure
make CXX=${CXX}
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
