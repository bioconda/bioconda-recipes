#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_ac.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_ac.py $PREFIX/bin/acpype_params_ac

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_cns.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_cns.py $PREFIX/bin/acpype_params_cns

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx.py $PREFIX/bin/acpype_params_gmx

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx_opls.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx_opls.py $PREFIX/bin/acpype_params_gmx_opls

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_add_hydrogens.py
cp $SP_DIR/biobb_chemistry/babelm/babel_add_hydrogens.py $PREFIX/bin/babel_add_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_convert.py
cp $SP_DIR/biobb_chemistry/babelm/babel_convert.py $PREFIX/bin/babel_convert

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_minimize.py
cp $SP_DIR/biobb_chemistry/babelm/babel_minimize.py $PREFIX/bin/babel_minimize

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_remove_hydrogens.py
cp $SP_DIR/biobb_chemistry/babelm/babel_remove_hydrogens.py $PREFIX/bin/babel_remove_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/ambertools/reduce_add_hydrogens.py
cp $SP_DIR/biobb_chemistry/ambertools/reduce_add_hydrogens.py $PREFIX/bin/reduce_add_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/ambertools/reduce_remove_hydrogens.py
cp $SP_DIR/biobb_chemistry/ambertools/reduce_remove_hydrogens.py $PREFIX/bin/reduce_remove_hydrogens
