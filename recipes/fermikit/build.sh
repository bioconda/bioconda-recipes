#!/bin/bash

mkdir -p $PREFIX/bin

make
mv fermi.kit/k8 fermi.kit/hapdip.js fermi.kit/run-calling $PREFIX/bin

