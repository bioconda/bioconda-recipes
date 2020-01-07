#!/bin/bash

mkdir -p $PREFIX/bin

qmake
make CC=$(CC) CXX=$(CXX) CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS)"
cp viz.x $PREFIX/bin

