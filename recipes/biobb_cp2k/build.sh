#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/cp2k_aux
cp -r biobb_cp2k/cp2k/cp2k_in $PREFIX/cp2k_aux
cp -r biobb_cp2k/cp2k/cp2k_data $PREFIX/cp2k_aux