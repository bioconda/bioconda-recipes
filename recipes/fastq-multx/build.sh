#!/bin/bash

rm fastq-multx
make

mkdir -p $PREFIX/bin
cp fastq-multx $PREFIX/bin
