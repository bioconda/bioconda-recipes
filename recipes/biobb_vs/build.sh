#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_vs/vina/autodock_vina.py
cp $SP_DIR/biobb_vs/vina/autodock_vina.py $PREFIX/bin/autodock_vina

chmod u+x $SP_DIR/biobb_vs/utils/bindingsite.py
cp $SP_DIR/biobb_vs/utils/bindingsite.py $PREFIX/bin/bindingsite

chmod u+x $SP_DIR/biobb_vs/utils/box.py
cp $SP_DIR/biobb_vs/utils/box.py $PREFIX/bin/box

chmod u+x $SP_DIR/biobb_vs/utils/box_residues.py
cp $SP_DIR/biobb_vs/utils/box_residues.py $PREFIX/bin/box_residues

chmod u+x $SP_DIR/biobb_vs/utils/extract_model_pdbqt.py
cp $SP_DIR/biobb_vs/utils/extract_model_pdbqt.py $PREFIX/bin/extract_model_pdbqt

chmod u+x $SP_DIR/biobb_vs/fpocket/fpocket.py
cp $SP_DIR/biobb_vs/fpocket/fpocket.py $PREFIX/bin/fpocket

chmod u+x $SP_DIR/biobb_vs/fpocket/fpocket_filter.py
cp $SP_DIR/biobb_vs/fpocket/fpocket_filter.py $PREFIX/bin/fpocket_filter

chmod u+x $SP_DIR/biobb_vs/fpocket/fpocket_select.py
cp $SP_DIR/biobb_vs/fpocket/fpocket_select.py $PREFIX/bin/fpocket_select
