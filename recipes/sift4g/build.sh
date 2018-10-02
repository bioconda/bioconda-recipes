#!/bin/bash

make -j 2
mkdir -p ${PREFIX}/bin
cp bin/* ${PREFIX}/bin
