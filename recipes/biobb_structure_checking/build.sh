#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_structure_checking/check_structure.py
cp $SP_DIR/biobb_structure_checking/check_structure.py $PREFIX/bin/check_structure
