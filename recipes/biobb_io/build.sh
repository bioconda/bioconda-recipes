#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_io/api/pdb.py
cp $SP_DIR/biobb_io/api/pdb.py $PREFIX/bin/pdb

chmod u+x $SP_DIR/biobb_io/api/pdb_cluster_zip.py
cp $SP_DIR/biobb_io/api/pdb_cluster_zip.py $PREFIX/bin/pdb_cluster_zip

chmod u+x $SP_DIR/biobb_io/api/pdb_variants.py
cp $SP_DIR/biobb_io/api/pdb_variants.py $PREFIX/bin/pdb_variants
