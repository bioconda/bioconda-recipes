#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_amber/ambpdb/amber_to_pdb.py
cp $SP_DIR/biobb_amber/ambpdb/amber_to_pdb.py $PREFIX/bin/amber_to_pdb

chmod u+x $SP_DIR/biobb_amber/cpptraj/cpptraj_randomize_ions.py
cp $SP_DIR/biobb_amber/cpptraj/cpptraj_randomize_ions.py $PREFIX/bin/cpptraj_randomize_ions

chmod u+x $SP_DIR/biobb_amber/leap/leap_add_ions.py
cp $SP_DIR/biobb_amber/leap/leap_add_ions.py $PREFIX/bin/leap_add_ions

chmod u+x $SP_DIR/biobb_amber/leap/leap_gen_top.py
cp $SP_DIR/biobb_amber/leap/leap_gen_top.py $PREFIX/bin/leap_gen_top

chmod u+x $SP_DIR/biobb_amber/leap/leap_solvate.py
cp $SP_DIR/biobb_amber/leap/leap_solvate.py $PREFIX/bin/leap_solvate

chmod u+x $SP_DIR/biobb_amber/leap/leap_build_linear_structure.py
cp $SP_DIR/biobb_amber/leap/leap_build_linear_structure.py $PREFIX/bin/leap_build_linear_structure

chmod u+x $SP_DIR/biobb_amber/nab/nab_build_dna_structure.py
cp $SP_DIR/biobb_amber/nab/nab_build_dna_structure.py $PREFIX/bin/nab_build_dna_structure

chmod u+x $SP_DIR/biobb_amber/parmed/parmed_cpinutil.py
cp $SP_DIR/biobb_amber/parmed/parmed_cpinutil.py $PREFIX/bin/parmed_cpinutil

chmod u+x $SP_DIR/biobb_amber/parmed/parmed_hmassrepartition.py
cp $SP_DIR/biobb_amber/parmed/parmed_hmassrepartition.py $PREFIX/bin/parmed_hmassrepartition

chmod u+x $SP_DIR/biobb_amber/pdb4amber/pdb4amber.py
cp $SP_DIR/biobb_amber/pdb4amber/pdb4amber.py $PREFIX/bin/pdb4amber

chmod u+x $SP_DIR/biobb_amber/pmemd/pmemd_mdrun.py
cp $SP_DIR/biobb_amber/pmemd/pmemd_mdrun.py $PREFIX/bin/pmemd_mdrun

chmod u+x $SP_DIR/biobb_amber/process/process_minout.py
cp $SP_DIR/biobb_amber/process/process_minout.py $PREFIX/bin/process_minout

chmod u+x $SP_DIR/biobb_amber/process/process_mdout.py
cp $SP_DIR/biobb_amber/process/process_mdout.py $PREFIX/bin/process_mdout

chmod u+x $SP_DIR/biobb_amber/sander/sander_mdrun.py
cp $SP_DIR/biobb_amber/sander/sander_mdrun.py $PREFIX/bin/sander_mdrun
