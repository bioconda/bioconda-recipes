#!/bin/bash
set -euo pipefail

mkdir build; cd build; cmake ..; make; cd ..

mkdir -p ${PREFIX}/bin
cp build/ksnp ${PREFIX}/bin
