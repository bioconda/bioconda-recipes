#!/bin/bash
cd 3seq-v1.8
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
if [ ! -d "$PREFIX/bin" ]; then
        mkdir $PREFIX/bin;
fi
cp ./3seq $PREFIX/bin/
if [ ! -d "$PREFIX/share" ]; then
	mkdir $PREFIX/share;
fi
mkdir $PREFIX/share/pval_table
wget -P $PREFIX/share/pval_table/ https://www.dropbox.com/s/zac4wotgdmm3mvb/pvaluetable.2017.700.tgz
tar xfz $PREFIX/share/pval_table/pvaluetable.2017.700.tgz  -C $PREFIX/share/pval_table/
3seq -c $PREFIX/share/pval_table/PVT.3SEQ.2017.700
