#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} \
  -Wall -O3 \
  -std=c++03 \
  -o "${PREFIX}/bin/grabix" \
  grabix_main.cpp grabix.cpp bgzf.c \
  ${LDFLAGS} -lstdc++ -lz
