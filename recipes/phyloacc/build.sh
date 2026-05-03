#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin
mkdir -p ${SP_DIR}

if [[ "${target_platform}" == osx-* ]]; then
	make -j ${CPU_COUNT} install \
		CXX="${CXX}" \
		CFLAGS="-Wall -g -O2 -std=c++14 -Xpreprocessor -fopenmp" \
		LDFLAGS="-lgsl -lm -lgslcblas -larmadillo -lomp"
else
	make -j ${CPU_COUNT} install CXX=${CXX}
fi

cp src/PhyloAcc-interface/phyloacc.py ${PREFIX}/bin/
ln -s ${PREFIX}/bin/phyloacc.py ${PREFIX}/bin/phyloacc
cp src/PhyloAcc-interface/phyloacc_post.py ${PREFIX}/bin/
cp -R src/PhyloAcc-interface/phyloacc_lib ${SP_DIR}/
