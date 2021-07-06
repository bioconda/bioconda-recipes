#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_model/model/mutate.py
cp $SP_DIR/biobb_model/model/mutate.py $PREFIX/bin/mutate

chmod u+x $SP_DIR/biobb_model/model/fix_side_chain.py
cp $SP_DIR/biobb_model/model/fix_side_chain.py $PREFIX/bin/fix_side_chain

chmod u+x $SP_DIR/biobb_model/model/fix_backbone.py
cp $SP_DIR/biobb_model/model/fix_backbone.py $PREFIX/bin/fix_backbone

chmod u+x $SP_DIR/biobb_model/model/fix_amides.py
cp $SP_DIR/biobb_model/model/fix_amides.py $PREFIX/bin/fix_amides

chmod u+x $SP_DIR/biobb_model/model/fix_chirality.py
cp $SP_DIR/biobb_model/model/fix_chirality.py $PREFIX/bin/fix_chirality

chmod u+x $SP_DIR/biobb_model/model/checking_log.py
cp $SP_DIR/biobb_model/model/checking_log.py $PREFIX/bin/checking_log
