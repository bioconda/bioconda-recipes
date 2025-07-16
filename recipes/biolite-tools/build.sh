#!/bin/bash
#error: invalid suffix on literal; C++11 requires a space between literal and identifier [-Wreserved-user-defined-literal]
for f in src/*.cpp; do
    sed -i.bak "s/PROGNAME/ PROGNAME /" $f
done
./configure --prefix="${PREFIX}" \
            CXXFLAGS="-I${PREFIX}/include" \
            LDFLAGS="-L${PREFIX}/lib"
make -j"${CPU_COUNT}"
make install
