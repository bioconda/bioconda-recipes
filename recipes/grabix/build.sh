#!/bin/bash

mkdir -p "${PREFIX}/bin"

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} \
  -Wall -O2 \
  -std=c++03 \
  -o "${PREFIX}/bin/"grabix \
  grabix_main.cpp grabix.cpp bgzf.c \
  ${LDFLAGS} -lstdc++ -lz
