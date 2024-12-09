#!/bin/bash
set -xe
#make CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="${CFLAGS} -g -Wall -O2 -L$PREFIX/lib"
g++ -o virdig assemble2.cpp load_reads2.cpp transcript.cpp utility.cpp 
chmod 777 ./virdig

