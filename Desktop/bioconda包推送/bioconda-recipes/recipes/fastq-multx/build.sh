#!/bin/bash
make CC=$CXX
mkdir -p "$PREFIX/bin"
cp fastq-multx "$PREFIX/bin"
