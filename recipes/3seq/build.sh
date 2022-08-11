#!/bin/bash
cd 3seq-v1.8
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
cp ./3seq $PREFIX/bin
mkdir $PREFIX/share/pval_table
wget -o $PREFIX/share/pval_table/pvaluetable.2017.700.tgz https://www.dropbox.com/s/zac4wotgdmm3mvb/pvaluetable.2017.700.tgz
tar xfz $PREFIX/share/pval_table/pvaluetable.2017.700.tgz
3seq -c $PREFIX/share/pval_table/PVT.3SEQ.2017.700
