#!/bin/bash

#make CXX=${CXX}
make install CXX=${CXX}
cp src/PhyloAcc-interface/phyloacc.py ${PREFIX}/bin/.
mkdir -p ${SP_DIR}
cp -R src/PhyloAcc-interface/phyloacc_lib ${SP_DIR}/.
