#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
mkdir -p "$PREFIX/bin"
PYTHON_SCRIPTS_DIR=$PREFIX/lib/R/library/DEXSeq/python_scripts
for f in dexseq_count.py dexseq_prepare_annotation.py; do
    sed -i.bak '1s|^|#!/usr/bin/env python\'$'\n|g' "$PYTHON_SCRIPTS_DIR/$f"
    chmod +x "$PYTHON_SCRIPTS_DIR/$f"
    ln -s "$PYTHON_SCRIPTS_DIR/$f" $PREFIX/bin/
