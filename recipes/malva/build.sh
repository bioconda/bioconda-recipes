#!/bin/bash

make

mkdir -p ${PREFIX}/bin
cp malva-geno ${PREFIX}/bin
cp MALVA ${PREFIX}/bin
