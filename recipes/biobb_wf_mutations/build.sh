#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $HOME/biobb_wf_mutations

cp -R $SP_DIR/biobb_wf_mutations/notebooks/mutations.ipynb $HOME/biobb_wf_mutations
