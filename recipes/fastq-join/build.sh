#!/bin/bash

make

mkdir -p $PREFIX/bin
cp fastq-join $PREFIX/bin
