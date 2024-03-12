#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX="${CXX}"
chmod +x coatran_*
cp coatran_* ${PREFIX}/bin
