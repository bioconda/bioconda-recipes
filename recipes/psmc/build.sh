#!/bin/bash

mkdir -p $PREFIX/bin
export MACHTYPE=x86_64
make
cp psmc $PREFIX/bin
cd utils && make
cp utils/* $PREFIX/bin
