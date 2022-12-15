#!/bin/bash

mkdir -p $PREFIX/bin
export MACHTYPE=x86_64
cp psmc $PREFIX/bin
cd utils && make CC=${CC}
cp utils/* $PREFIX/bin
