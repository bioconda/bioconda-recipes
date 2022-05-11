#!/bin/bash

mkdir -p ${PREFIX}/bin

make
mv $PWD/bin/* ${PREFIX}/bin
