#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX=${CXX}
cp coatran_* ${PREFIX}/bin
