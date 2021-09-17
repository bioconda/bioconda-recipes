#!/bin/bash -e

c++ -O3 -Wall -I. -I${BUILD_PREFIX}/include -c sracat.cpp
c++ -o ${PREFIX}/bin/sracat sracat.o -lm -lz -lpthread -L${BUILD_PREFIX}/lib64 \
    -lncbi-ngs-c++ -lncbi-ngs -lngs-c++ -lncbi-vdb-static -ldl
