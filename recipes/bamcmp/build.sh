#!/bin/bash

cd bamcmp-master || true
make CPP=$CXX
cp build/bamcmp $PREFIX/bin/
