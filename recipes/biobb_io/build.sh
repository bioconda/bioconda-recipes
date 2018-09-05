#!/usr/bin/env bash

python setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin
cp  $SP_DIR/biobb_io/mmb_api/pdb.py $PREFIX/bin/
cp  $SP_DIR/biobb_io/mmb_api/pdb_cluster_zip.py $PREFIX/bin/
cp  $SP_DIR/biobb_io/mmb_api/pdb_variants.py $PREFIX/bin/
