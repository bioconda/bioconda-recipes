#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/msms"

# Look for `atmtypenumbers` in the library folder instead of the current folder
sed -i "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/lib/msms/atmtypenumbers\"|" pdb_to_xyzr
sed -i "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/lib/msms/atmtypenumbers\"|" pdb_to_xyzrn

# Copy files to the conda bin/ folder
cp ./pdb_to_xyzr $PREFIX/bin
cp ./pdb_to_xyzrn $PREFIX/bin
cp ./msms.x86_64Linux2.2.6.1 $PREFIX/bin/msms
cp ./atmtypenumbers $PREFIX/lib/msms

chmod +x $PREFIX/bin/pdb_to_xyzr
chmod +x $PREFIX/bin/pdb_to_xyzrn

