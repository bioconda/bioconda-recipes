#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p ~/mutations
ls $SP_DIR
cwd
ls -R $SP_DIR/biobb_wf_mutations
cp $SP_DIR/biobb_wf_mutations/notebooks/mutations.ipynb ~/mutations/
