#!/bin/bash

$PYTHON -m pip install . --no-deps --ignore-installed -vv

# Clean up any extraneous OSX files in the DB archive
rm BLAST_dbs/._*
# Install databases
mv BLAST_dbs $PREFIX/lib/python3.*/site-packages/plannotate/data/
