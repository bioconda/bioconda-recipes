#!/bin/bash

mkdir -p ${PREFIX}/bin

make install CC="${CC}" -j"${CPU_COUNT}"
