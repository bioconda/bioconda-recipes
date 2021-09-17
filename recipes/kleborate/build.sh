#! /bin/bash

{{ PYTHON }} -m pip install . --ignore-installed --no-deps -vv

# Make blastdbs of Kleborate data
# Allows containters to be usable
kleborate -a kleborate/data Klebsiella_pneumoniae.fasta --all
