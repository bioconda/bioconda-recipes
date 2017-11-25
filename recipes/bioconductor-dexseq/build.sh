#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .

python_scripts=$PREFIX/lib/R/library/DEXSeq/python_scripts

if [ "$PY3K" == 1 ]; then
    2to3 -w $python_scripts/dexseq_count.py
    2to3 -w $python_scripts/dexseq_prepare_annotation.py
fi

chmod +x $python_scripts/dexseq_count.py
chmod +x $python_scripts/dexseq_prepare_annotation.py

sed -i'' -e '1 i\'$'\n''#!/usr/bin/env python' $python_scripts/dexseq_count.py
sed -i'' -e '1 i\'$'\n''#!/usr/bin/env python' $python_scripts/dexseq_prepare_annotation.py

mkdir -p $PREFIX/bin
ln -s $python_scripts/dexseq_count.py $PREFIX/bin/dexseq_count.py
ln -s $python_scripts/dexseq_prepare_annotation.py $PREFIX/bin/dexseq_prepare_annotation.py
