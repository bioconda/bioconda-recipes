#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX=${CXX}
cp {coatran_constant,coatran_expgrowth,coatran_transtree,coatran_inftime} ${PREFIX}/bin
