#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-writable-strings -Wno-literal-suffix"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++14 -O3 -Wformat -Wno-reserved-user-defined-literal"

sed -i.bak '/char nucToNum/s/^/signed\ /g' defs.h
sed -i.bak '/char numToNuc/s/^/signed\ /g' defs.h
sed -i.bak 's/extern char nucToNum/extern signed char nucToNum/g' KmerCode.hpp
sed -i.bak 's/extern char numToNuc/extern signed char numToNuc/g' KmerCode.hpp
sed -i.bak 's/extern char nucToNum/extern signed char nucToNum/g' genome.hpp
sed -i.bak 's/extern char numToNuc/extern signed char numToNuc/g' genome.hpp
sed -i.bak 's/-lpthread/-pthread/g' Makefile

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' *.pl
rm -rf *.bak

make CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" LINKPATH="${LDFLAGS}" \
    -j"${CPU_COUNT}"

install -v -m 755 \
    *.pl \
    rascaf \
    rascaf-join \
    "${PREFIX}/bin"
