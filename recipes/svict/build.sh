#!/bin/bash

export CPATH=${PREFIX}/include

make
mkdir -p ${PREFIX}/bin
cp -f svict ${PREFIX}/bin

