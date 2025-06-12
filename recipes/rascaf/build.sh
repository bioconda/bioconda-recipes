#!/bin/bash

sed -i '/char nucToNum/s/^/signed\ /g' defs.h
sed -i '/char numToNuc/s/^/signed\ /g' defs.h
sed -i 's/extern char nucToNum/extern signed char nucToNum/g' KmerCode.hpp
sed -i 's/extern char numToNuc/extern signed char numToNuc/g' KmerCode.hpp
sed -i 's/extern char nucToNum/extern signed char nucToNum/g' genome.hpp
sed -i 's/extern char numToNuc/extern signed char numToNuc/g' genome.hpp

make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS}"
install -d "${PREFIX}/bin"
install \
    *.pl \
    rascaf \
    rascaf-join \
    "${PREFIX}/bin/"
