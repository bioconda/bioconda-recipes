#!/bin/bash

make

mkdir -p $PREFIX/bin
cp fastq-multx $PREFIX/bin
