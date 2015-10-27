#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/msms"

# Look for `atmtypenumbers` in the library folder instead of the current folder
sed -i "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/lib/msms/atmtypenumbers\"|" pdb_to_xyzr
sed -i "s|numfile = \"./atmtypenumbers\"|numfile = \"$PREFIX/lib/msms/atmtypenumbers\"|" pdb_to_xyzrn

# Change `nawk` to `awk`, since `nawk` is not installed on some platforms
sed -i 's|nawk|awk|g' pdb_to_xyzrn

# Patch pdb_to_xyzrn so that it includes the chain in its output
sed -i 's|resnum=substr($0,23,4);|resnum=substr($0,23,4);\n\tchain=substr($0,21,2);|' pdb_to_xyzrn
sed -i 's|gsub(" ", "", aname);|gsub(" ", "", aname);\n\tgsub(" ", "", resnum);\n\tgsub(" ", "", chain);|' pdb_to_xyzrn
sed -i 's|"%f %f %f %f %d %s_%s_%d\\n", x, y, z, |"%f %f %f %f %d %s_%s_%d_%s\\n", x, y, z, |g' pdb_to_xyzrn
sed -i 's|1, aname, resname, resnum);|1, aname, resname, resnum, chain);|g' pdb_to_xyzrn

# Copy files to the conda bin/ folder
cp ./pdb_to_xyzr $PREFIX/bin
cp ./pdb_to_xyzrn $PREFIX/bin
cp ./msms.x86_64Linux2.2.6.1 $PREFIX/bin/msms
cp ./atmtypenumbers $PREFIX/lib/msms

chmod +x $PREFIX/bin/pdb_to_xyzr
chmod +x $PREFIX/bin/pdb_to_xyzrn

