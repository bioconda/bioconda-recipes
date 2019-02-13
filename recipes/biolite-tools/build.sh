#!/bin/bash
./configure --prefix="${PREFIX}" \
            CXXFLAGS="-I${PREFIX}/include" \
            LDFLAGS="-L${PREFIX}/lib"
make -j"${CPU_COUNT}"
make install
