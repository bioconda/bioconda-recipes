#!/bin/bash

mkdir -p $PREFIX/lib
cp -R src/* $PREFIX/bin
cp -R lib/PhaME.pm $PREFIX/lib
cp -R lib/misc_funcs.pm $PREFIX/lib
cp -R lib/fastq_utility.pm $PREFIX/lib