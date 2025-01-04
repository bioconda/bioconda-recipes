#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin

cd src

$CC -o $PREFIX/bin/apu-label-propagation apu_label_propagation.c -lm

chmod u+x ${PREFIX}/bin/apu-label-propagation
