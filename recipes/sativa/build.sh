#!/bin/bash

export USE_AVX=yes
export USE_AVX2=yes

make -C raxml

cp -r raxml ${PREFIX}/bin
cp -r epac ${PREFIX}/bin
cp *.py ${PREFIX}/bin
cp sativa.cfg ${PREFIX}/bin
