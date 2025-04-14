#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/msms"

# Look for `atmtypenumbers` in the library folder instead of the current folder
sed -i.bak "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/lib/msms/atmtypenumbers\"|" pdb_to_xyzr
sed -i.bak "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/lib/msms/atmtypenumbers\"|" pdb_to_xyzrn

# Copy files to the conda bin/ folder
cp ./pdb_to_xyzr $PREFIX/bin
cp ./pdb_to_xyzrn $PREFIX/bin
cp ./msms.*.$PKG_VERSION $PREFIX/bin/msms
cp ./atmtypenumbers $PREFIX/lib/msms

chmod +x $PREFIX/bin/pdb_to_xyzr
chmod +x $PREFIX/bin/pdb_to_xyzrn

