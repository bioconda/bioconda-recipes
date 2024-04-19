#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${SP_DIR}

make install CXX=${CXX}

cp src/PhyloAcc-interface/phyloacc.py ${PREFIX}/bin/
ln -s ${PREFIX}/bin/phyloacc.py ${PREFIX}/bin/phyloacc
cp src/PhyloAcc-interface/phyloacc_post.py ${PREFIX}/bin/
cp -R src/PhyloAcc-interface/phyloacc_lib ${SP_DIR}/
