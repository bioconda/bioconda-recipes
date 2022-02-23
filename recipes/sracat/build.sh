#!/bin/bash -e

$CXX ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -O3 -Wall \
     -I. -I${PREFIX}/include -c sracat.cpp
$CXX ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -o ${PREFIX}/bin/sracat sracat.o \
    -lm -lz -lpthread -L${PREFIX}/lib64 \
    -lncbi-ngs-c++ -lncbi-ngs -lngs-c++ -lncbi-vdb-static -ldl
