#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p ~/mutations
cp -R notebooks/mutations.ipynb ~/biobb_wf_mutations
