#!/bin/bash

set -xe

## compile
${CXX} -c consensify_c.cpp -I./ ${CXXFLAGS}

## link
${CXX} consensify_c.o -o consensify_c -lz ${LDFLAGS}

## install
mkdir -p $PREFIX/bin
cp consensify_c ${PREFIX}/bin/consensify_c
