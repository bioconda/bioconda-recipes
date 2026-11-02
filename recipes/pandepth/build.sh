#!/bin/bash
set -eu -o pipefail

${CXX} ${CXXFLAGS} ${LDFLAGS} --std=c++11 -g -O3 src/PanDepth.cpp \
    -lhts -ldeflate -lz -pthread \
    -I${PREFIX}/include -Iinclude -L${PREFIX}/lib -o pandepth

cp pandepth ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/pandepth
