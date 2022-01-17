#!/bin/bash

cd bamcmp-2.1 || true
make CPP=$CXX
cp build/bamcmp $PREFIX/bin
