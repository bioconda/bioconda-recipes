#!/bin/bash

cd bamcmp-2.2 || true
make CPP=$CXX
mkdir -p $PREFIX/bin
cp build/bamcmp $PREFIX/bin/
