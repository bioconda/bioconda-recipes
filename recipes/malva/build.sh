#!/bin/bash

tar xfz kmc_api.tar.gz

make

mkdir -p ${PREFIX}/bin
cp malva-geno ${PREFIX}/bin
cp MALVA ${PREFIX}/bin
