#!/bin/bash

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
if [ ! -d "$PREFIX/bin" ]; then
        mkdir $PREFIX/bin;
        export PATH=$PREFIX/bin:$PATH;
fi
cp ./3seq $PREFIX/bin/
if [ ! -d "$PREFIX/share/3seq" ]; then
	mkdir $PREFIX/share/3seq;
fi
wget -P $PREFIX/share/3seq/ https://www.dropbox.com/s/zac4wotgdmm3mvb/pvaluetable.2017.700.tgz
tar xfz $PREFIX/share/3seq/pvaluetable.2017.700.tgz  -C $PREFIX/share/3seq/
echo "yes | 3seq -c $PREFIX/share/3seq/PVT.3SEQ.2017.700" > pval_check.sh; chmod +x pval_check.sh; (timeout 5 ./pval_check.sh &> log.out & exit 0)
