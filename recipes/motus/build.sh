#!/bin/bash

# Execute tool with dummy file to trigger the creation of motus_data folder
touch dummy.fq
./mOTUs.pl dummy.fq 2> /dev/null || true

# Remove blob from the script
sed -i '/__DATA__/q' mOTUs.pl

# Creates a symbolic link from opt/ to bin/ because of the motus_data folder which contains some binaries (from blob text in the file)
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/motus/
cp -r mOTUs.pl motus_data $PREFIX/opt/motus/
ln -s $PREFIX/opt/motus/mOTUs.pl $PREFIX/bin/
