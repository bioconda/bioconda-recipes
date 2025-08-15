#!/bin/bash

echo "Compiling Canopy"
mkdir -p ${PREFIX}/bin
make
mv cc.bin ${PREFIX}/bin/
