#!/bin/bash

mkdir -p ${PREFIX}/bin

make
mv ${pwd}/bin/* ${PREFIX}/bin
