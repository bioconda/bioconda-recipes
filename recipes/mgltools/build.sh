#!/bin/bash
./install.sh -d $PREFIX

BINARY_HOME=$PREFIX/bin
UTILITIES_HOME=$PREFIX/MGLToolsPckgs/AutoDockTools/Utilities24
ln -s $UTILITIES_HOME/prepare_ligand4.py $BINARY_HOME/prepare_ligand4.py
ln -s $UTILITIES_HOME/prepare_receptor4.py $BINARY_HOME/prepare_receptor4.py