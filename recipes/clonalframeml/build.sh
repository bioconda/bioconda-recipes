#!/bin/bash
mkdir -p $PREFIX/bin
cd src
make CC=$CXX
mv ClonalFrameML ${PREFIX}/bin/
