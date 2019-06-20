#!/bin/bash

mkdir -p ${PREFIX}/bin
make bin
make
cp ../bin/Red ${PREFIX}/bin
