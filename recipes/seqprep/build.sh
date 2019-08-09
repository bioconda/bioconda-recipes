#!/bin/sh

mkdir -p ${PREFIX}/bin
make
cp SeqPrep ${PREFIX}/bin
