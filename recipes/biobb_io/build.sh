#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_io/api/drugbank.py
cp $SP_DIR/biobb_io/api/drugbank.py $PREFIX/bin/drugbank

chmod u+x $SP_DIR/biobb_io/api/ligand.py
cp $SP_DIR/biobb_io/api/ligand.py $PREFIX/bin/ligand

chmod u+x $SP_DIR/biobb_io/api/memprotmd_sim.py
cp $SP_DIR/biobb_io/api/memprotmd_sim.py $PREFIX/bin/memprotmd_sim

chmod u+x $SP_DIR/biobb_io/api/memprotmd_sim_list.py
cp $SP_DIR/biobb_io/api/memprotmd_sim_list.py $PREFIX/bin/memprotmd_sim_list

chmod u+x $SP_DIR/biobb_io/api/memprotmd_sim_search.py
cp $SP_DIR/biobb_io/api/memprotmd_sim_search.py $PREFIX/bin/memprotmd_sim_search

chmod u+x $SP_DIR/biobb_io/api/pdb.py
cp $SP_DIR/biobb_io/api/pdb.py $PREFIX/bin/pdb

chmod u+x $SP_DIR/biobb_io/api/pdb_cluster_zip.py
cp $SP_DIR/biobb_io/api/pdb_cluster_zip.py $PREFIX/bin/pdb_cluster_zip

chmod u+x $SP_DIR/biobb_io/api/pdb_variants.py
cp $SP_DIR/biobb_io/api/pdb_variants.py $PREFIX/bin/pdb_variants
