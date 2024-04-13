#!/bin/bash

mkdir -p ${PREFIX}/bin
make CC=${CC}
cp GEMF GEMF_FAVITES.py ${PREFIX}/bin
