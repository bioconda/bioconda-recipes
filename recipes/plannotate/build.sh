#!/bin/bash
set -ex
$PYTHON -m pip install . --no-deps --ignore-installed -vv

# Clean up any extraneous OSX files in the DB archive
rm BLAST_dbs/._*
# Install databases
bpath=`python -c "import sys; print(sys.path[-1])"`
mv BLAST_dbs $bpath/plannotate/data/
