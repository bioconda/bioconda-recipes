#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_model/model/mutate.py
cp $SP_DIR/biobb_model/model/mutate.py $PREFIX/bin/mutate

chmod u+x $SP_DIR/biobb_model/model/fix_side_chain.py
cp $SP_DIR/biobb_model/model/fix_side_chain.py $PREFIX/bin/fix_side_chain
