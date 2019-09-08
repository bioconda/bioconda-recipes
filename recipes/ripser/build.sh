#!/bin/bash

mkdir -p ${PREFIX}/bin
make all
cp {ripser,ripser-debug,ripser-coeff} ${PREFIX}/bin
