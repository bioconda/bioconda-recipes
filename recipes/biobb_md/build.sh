#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_md/gromacs/editconf.py
cp $SP_DIR/biobb_md/gromacs/editconf.py $PREFIX/bin/editconf

chmod u+x $SP_DIR/biobb_md/gromacs/genion.py
cp $SP_DIR/biobb_md/gromacs/genion.py $PREFIX/bin/genion

chmod u+x $SP_DIR/biobb_md/gromacs/genrestr.py
cp $SP_DIR/biobb_md/gromacs/genrestr.py $PREFIX/bin/genrestr

chmod u+x $SP_DIR/biobb_md/gromacs/grompp.py
cp $SP_DIR/biobb_md/gromacs/grompp.py $PREFIX/bin/grompp

chmod u+x $SP_DIR/biobb_md/gromacs/make_ndx.py
cp $SP_DIR/biobb_md/gromacs/make_ndx.py $PREFIX/bin/make_ndx

chmod u+x $SP_DIR/biobb_md/gromacs/mdrun.py
cp $SP_DIR/biobb_md/gromacs/mdrun.py $PREFIX/bin/mdrun

chmod u+x $SP_DIR/biobb_md/gromacs/pdb2gmx.py
cp $SP_DIR/biobb_md/gromacs/pdb2gmx.py $PREFIX/bin/pdb2gmx

chmod u+x $SP_DIR/biobb_md/gromacs/solvate.py
cp $SP_DIR/biobb_md/gromacs/solvate.py $PREFIX/bin/solvate

chmod u+x $SP_DIR/biobb_md/gromacs_extra/ndx2resttop.py
cp $SP_DIR/biobb_md/gromacs_extra/ndx2resttop.py $PREFIX/bin/ndx2resttop

chmod u+x $SP_DIR/biobb_md/gromacs_extra/append_ligand.py
cp $SP_DIR/biobb_md/gromacs_extra/append_ligand.py $PREFIX/bin/append_ligand
