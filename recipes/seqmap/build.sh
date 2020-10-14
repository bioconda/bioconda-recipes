#!/bin/bash

mkdir -p "${PREFIX}/bin"

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} -o "${PREFIX}/bin/seqmap" match.cpp
