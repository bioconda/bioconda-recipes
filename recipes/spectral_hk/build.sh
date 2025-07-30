#!/bin/bash

make
mkdir -p $PREFIX/bin
cp spectral_hk $PREFIX/bin/
