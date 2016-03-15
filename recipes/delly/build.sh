#!/bin/bash

mkdir -p $PREFIX/bin

make STATIC=1 PARALLEL=1 -B src/delly
cp src/delly $PREFIX/bin/delly
