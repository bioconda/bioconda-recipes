#!/bin/bash

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX
make
if [ ! -d "$CONDA_PREFIX/bin" ]; then
        mkdir $PREFIX/bin;
fi
cp ./3seq $CONDA_PREFIX/bin/
if [ ! -d "$CONDA_PREFIX/share" ]; then
	mkdir $CONDA_PREFIX/share;
fi
mkdir $CONDA_PREFIX/share/pval_table
wget -P $CONDA_PREFIX/share/pval_table/ https://www.dropbox.com/s/zac4wotgdmm3mvb/pvaluetable.2017.700.tgz
tar xfz $CONDA_PREFIX/share/pval_table/pvaluetable.2017.700.tgz  -C $CONDA_PREFIX/share/pval_table/
3seq -c $CONDA_PREFIX/share/pval_table/PVT.3SEQ.2017.700
