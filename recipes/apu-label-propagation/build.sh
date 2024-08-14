#!/bin/bash
mkdir -p ${PREFIX}/bin

cd src

$CC -o $PREFIX/bin/apu-label-propagation apu_label_propagation.c -lm

#cp ./apu-label-propagation ${PREFIX}/bin/
