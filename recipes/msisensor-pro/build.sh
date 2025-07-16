#!/bin/bash

mkdir -p ${PREFIX}/bin

make -C cpp CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"
chmod 0755 cpp/msisensor-pro
mv cpp/msisensor-pro ${PREFIX}/bin
