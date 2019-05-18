#!/bin/sh

make
chmod +x SoftSV
mkdir -p ${PREFIX}/bin
cp SoftSV ${PREFIX}/bin
