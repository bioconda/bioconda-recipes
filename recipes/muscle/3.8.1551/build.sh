#!/bin/bash

make GPP=$CXX -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/bin/ 
install -m 0755 muscle ${PREFIX}/bin/ 
