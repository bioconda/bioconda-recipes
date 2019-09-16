#!/bin/bash
set -e -x
mkdir -p $PREFIX/bin

make
cp ./fastq-scan $PREFIX/bin
