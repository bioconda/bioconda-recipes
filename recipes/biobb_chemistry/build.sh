#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx.py $PREFIX/bin/acpype_params_gmx

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_add_hydrogens.py
cp $SP_DIR/biobb_chemistry/babelm/babel_add_hydrogens.py $PREFIX/bin/babel_add_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_convert.py
cp $SP_DIR/biobb_chemistry/babelm/babel_convert.py $PREFIX/bin/babel_convert

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_minimize.py
cp $SP_DIR/biobb_chemistry/babelm/babel_minimize.py $PREFIX/bin/babel_minimize

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_remove_hydrogens.py
cp $SP_DIR/biobb_chemistry/babelm/babel_remove_hydrogens.py $PREFIX/bin/babel_remove_hydrogens

