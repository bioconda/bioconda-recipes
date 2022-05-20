#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
wget https://raw.githubusercontent.com/Zilong-Li/PCAone/main/conda.makefile
make -f conda.makefile
mv PCAone ${PREFIX}/bin/
