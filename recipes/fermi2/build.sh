#!/bin/bash

mkdir -p $PREFIX/bin

make
mv fermi2  $PREFIX/bin
mv fermi2.pl  $PREFIX/bin

