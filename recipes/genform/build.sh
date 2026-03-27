#!/bin/bash

mkdir -p "$PREFIX/bin"

${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} ./src/*.cpp -o genform

install -v -m 0755 genform "$PREFIX/bin"
