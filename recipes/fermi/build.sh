#!/bin/bash

mkdir -p $PREFIX/bin

make 
mv fermi  $PREFIX/bin
mv run-fermi.pl $PREFIX/bin
