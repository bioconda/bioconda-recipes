#!/usr/bin/env bash

cd tabix-0.2.5
make lib
cd -

cd samtools-0.1.16
make lib
cd -

# This patch has not been fed upstream
sed -i.bak 's/=/\?=/g' makefile

# This getopt.h appears to be included through sam.h for the other .cpp files
# Not yet reported to upstream
sed -i.bak 's/using/#include <getopt.h>\nusing/' poprob.cpp

make all CC=$CXX\
     INCLUDE="-Wall -Wextra -O3 -fopenmp -I$PREFIX/include -Itabix-0.2.5 -Isamtools-0.1.16" \
     LIBS="-L$PREFIX/lib ./samtools-0.1.16/libbam.a ./tabix-0.2.5/libtabix.a -lgomp -lpthread -lgsl -lgslcblas -lz -lbz2"

install bamodel poprob probin impute hapfuse $PREFIX/bin

