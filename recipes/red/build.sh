#!/bin/bash

cd src_2.0

mkdir -p ${PREFIX}/bin
make bin
make
cp ../bin/Red ${PREFIX}/bin
