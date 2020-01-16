#!/bin/bash

export LD_LIBRARY_PATH=${PREFIX}/lib
export LIBRARY_PATH=${PREFIX}/lib

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build .
mkdir -p ${PREFIX}/bin
mv coinfinder ${PREFIX}/bin

mkdir -p ${PREFIX}/bin/coinfind-code/
mv coinfind-code/check_zeroes.R ${PREFIX}/bin/coinfind-code/
mv coinfind-code/create_roary.py ${PREFIX}/bin/coinfind-code/
mv coinfind-code/format_roary.py ${PREFIX}/bin/coinfind-code/
mv coinfind-code/helper_label_internal_nodes.py ${PREFIX}/bin/coinfind-code/
mv coinfind-code/lineage.R ${PREFIX}/bin/coinfind-code/
mv coinfind-code/network.R ${PREFIX}/bin/coinfind-code/
mv coinfind-code/network_nophylogeny.R ${PREFIX}/bin/coinfind-code/
