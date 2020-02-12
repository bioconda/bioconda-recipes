#!/bin/bash

${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} ./src/*.cpp -o genform
mkdir -p "$PREFIX"/bin/
mv genform "$PREFIX"/bin/
