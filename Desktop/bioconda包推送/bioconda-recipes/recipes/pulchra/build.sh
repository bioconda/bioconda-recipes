#!/bin/bash
set -x
mkdir -p $PREFIX/bin
$CC -O3 -o $PREFIX/bin/pulchra pulchra.c pulchra_data.c -lm
