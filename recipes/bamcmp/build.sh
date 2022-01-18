#!/bin/bash

cd bamcmp-master || true
make CPP=$CXX
mkdir -p $PREFIX/bin
cp build/bamcmp $PREFIX/bin/
