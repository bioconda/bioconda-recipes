#!/bin/bash

mkdir -p $PREFIX/bin

git clone https://github.com/lh3/seqtk.git
cd seqtk
make
cp seqtk $PREFIX/bin

bash install_dDocent_requirements $PREFIX/bin

chmod +x $PREFIX/bin/dDocent
