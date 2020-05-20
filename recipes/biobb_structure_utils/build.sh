#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_structure_utils/utils/cat_pdb.py
cp $SP_DIR/biobb_structure_utils/utils/cat_pdb.py $PREFIX/bin/cat_pdb

chmod u+x $SP_DIR/biobb_structure_utils/utils/extract_atoms.py
cp $SP_DIR/biobb_structure_utils/utils/extract_atoms.py $PREFIX/bin/extract_atoms

chmod u+x $SP_DIR/biobb_structure_utils/utils/extract_chain.py
cp $SP_DIR/biobb_structure_utils/utils/extract_chain.py $PREFIX/bin/extract_chain

chmod u+x $SP_DIR/biobb_structure_utils/utils/extract_heteroatoms.py
cp $SP_DIR/biobb_structure_utils/utils/extract_heteroatoms.py $PREFIX/bin/extract_heteroatoms

chmod u+x $SP_DIR/biobb_structure_utils/utils/extract_model.py
cp $SP_DIR/biobb_structure_utils/utils/extract_model.py $PREFIX/bin/extract_model

chmod u+x $SP_DIR/biobb_structure_utils/utils/extract_protein.py
cp $SP_DIR/biobb_structure_utils/utils/extract_protein.py $PREFIX/bin/extract_protein

chmod u+x $SP_DIR/biobb_structure_utils/utils/remove_ligand.py
cp $SP_DIR/biobb_structure_utils/utils/remove_ligand.py $PREFIX/bin/remove_ligand

chmod u+x $SP_DIR/biobb_structure_utils/utils/remove_pdb_water.py
cp $SP_DIR/biobb_structure_utils/utils/remove_pdb_water.py $PREFIX/bin/remove_pdb_water

chmod u+x $SP_DIR/biobb_structure_utils/utils/renumber_structure.py
cp $SP_DIR/biobb_structure_utils/utils/renumber_structure.py $PREFIX/bin/renumber_structure

chmod u+x $SP_DIR/biobb_structure_utils/utils/sort_gro_residues.py
cp $SP_DIR/biobb_structure_utils/utils/sort_gro_residues.py $PREFIX/bin/sort_gro_residues