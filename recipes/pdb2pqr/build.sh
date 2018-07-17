#!/bin/bash
mkdir -p $PREFIX/pdb2pqr
mkdir -p $PREFIX/bin
$PYTHON scons/scons.py PREFIX=$PREFIX/pdb2pqr
$PYTHON scons/scons.py install PREFIX=$PREFIX/pdb2pqr
mv $PREFIX/pdb2pqr/pdb2pqr.py  $PREFIX/pdb2pqr/pdb2pqr.py.tmp
echo '#! /usr/bin/env python' > $PREFIX/pdb2pqr/pdb2pqr.py
tail -n +2 $PREFIX/pdb2pqr/pdb2pqr.py.tmp >> $PREFIX/pdb2pqr/pdb2pqr.py
chmod 0766 $PREFIX/pdb2pqr/pdb2pqr.py
ln -s $PREFIX/pdb2pqr/pdb2pqr.py $PREFIX/bin/pdb2pqr
