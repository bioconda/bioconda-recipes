#!/bin/bash
export SAMTOOLS_ROOT=$PREFIX/include
make
make install
mkdir -p $PREFIX/bin
cp msisensor $PREFIX/bin
