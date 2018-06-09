#!/bin/bash

mkdir -p $PREFIX/bin

bash install_dDocent_requirements $PREFIX/bin

chmod +x $PREFIX/bin/dDocent

git clone https://github.com/lh3/seqtk.git

cd seqtk
make
cp seqtk $PREFIX/bin
