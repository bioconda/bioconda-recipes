#!/bin/bash

make GPP=$CXX -j"${CPU_COUNT}"

install -m 0755 muscle ${PREFIX}/bin/ 
