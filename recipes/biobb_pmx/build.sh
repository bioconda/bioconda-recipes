#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_pmx/pmx/pmxmutate.py
cp $SP_DIR/biobb_pmx/pmx/pmxmutate.py $PREFIX/bin/pmxmutate

chmod u+x $SP_DIR/biobb_pmx/pmx/pmxanalyse.py
cp $SP_DIR/biobb_pmx/pmx/pmxanalyse.py $PREFIX/bin/pmxanalyse

chmod u+x $SP_DIR/biobb_pmx/pmx/pmxgentop.py
cp $SP_DIR/biobb_pmx/pmx/pmxgentop.py $PREFIX/bin/pmxgentop
