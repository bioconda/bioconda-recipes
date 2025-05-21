#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p ${PREFIX}/bin

# python PLEK_setup.py
$CXX -O3 -c svm.cpp
$CC -g -Wall -O3 svm-train.c svm.o -o svm-train -lstdc++ -lm
$CC -g -Wall -O3 svm-predict.c svm.o -o svm-predict  -lstdc++ -lm
$CC -g -Wall -O3 svm-scale.c svm.o -o svm-scale  -lstdc++ -lm
$CC -g -Wall -O3 PLEK_main.c -o PLEK -lm
$CC -g -Wall -O3 PLEK_spsn.c -o PLEK_spsn -lm

chmod +x *.py
chmod +x *.R
install -v -m 0755 PLEK PLEK.model PLEK_spsn PLEK.range svm-predict svm-scale svm-train ${PREFIX}/bin
cp -f *.py ${PREFIX}/bin
cp -f *.R ${PREFIX}/bin
