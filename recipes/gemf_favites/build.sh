#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX=${CXX}
cp GEMF GEMF_FAVITES.py ${PREFIX}/bin
