#!/bin/bash

install -d "${PREFIX}/bin"
# Copy the precompiled ideas binary.
install ./bin/linux/ideas "${PREFIX}/bin/"
# Compile and install prepMat from source.
"${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} \
    ./src/prepareMatrix.cpp \
    -o "${PREFIX}/bin/prepMat"
