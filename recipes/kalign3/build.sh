#!/bin/bash
set -eo pipefail

mkdir build
cd build
cmake .. 
make 
make test 
make install
