#!/bin/bash

mkdir -p ${PREFIX}/bin

make
make PREFIX=${PREFIX} install
