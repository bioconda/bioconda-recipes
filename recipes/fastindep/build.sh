#!/bin/bash

mkdir -p "${PREFIX}/bin"
"${CXX}" ${CXXFLAGS} ${CPPFLAGS} -Wall -o "${PREFIX}/bin/fastindep" -O main.cpp DataMethods.cpp
"${CXX}" ${CXXFLAGS} ${CPPFLAGS} -Wall -o "${PREFIX}/bin/fastindep-symmetry" -O check_symm.cpp
