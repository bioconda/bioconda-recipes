#!/bin/bash

mkdir -p "${PREFIX}/bin"
${CXX} ${CXXFLAGS} ${CPPFLAGS} -std=c++0x -O3 -o "${PREFIX}/bin/splitMEM" splitMEM.cc
