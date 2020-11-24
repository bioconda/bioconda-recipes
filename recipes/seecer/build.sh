#!/bin/bash
cd SEECER
./configure --prefix=$PREFIX
make
make install
cp bin/run_seecer.sh $PREFIX/bin/
chmod +x bin/run_seecer.sh