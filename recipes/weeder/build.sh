#!/bin/bash

TGT=${PREFIX}/share/weeder2
mkdir -p ${PREFIX}/bin
mkdir -p ${TGT}

cp -r FreqFiles ${TGT}
$CXX weeder2.cpp -o ${TGT}/weeder2 -O3

cp ${RECIPE_DIR}/weeder2.py ${PREFIX}/bin/weeder2
chmod 0755 ${PREFIX}/bin/weeder2
