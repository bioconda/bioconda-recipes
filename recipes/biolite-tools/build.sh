#!/bin/bash
#error: invalid suffix on literal; C++11 requires a space between literal and identifier [-Wreserved-user-defined-literal]
sed -i.bak "s/PROGNAME/ PROGNAME /" tools/src/coverage.cpp
sed -i.bak "s/PROGNAME/ PROGNAME /" tools/src/exclude.cpp
./configure --prefix="${PREFIX}" \
            CXXFLAGS="-I${PREFIX}/include" \
            LDFLAGS="-L${PREFIX}/lib"
make -j"${CPU_COUNT}"
make install
