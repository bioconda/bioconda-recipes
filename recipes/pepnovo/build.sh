#!/bin/bash

mkdir -p ${PREFIX}/bin
cd src/
make
cp PepNovo_bin ${PREFIX}/bin/pepnovo
