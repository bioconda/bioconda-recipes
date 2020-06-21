#!/bin/bash

cd bin

rm -dr lib include
gcc -g -O3 -xc++ -lstdc++ -shared-libgcc -std=c++11 -I $PREFIX/include -L $PREFIX/lib -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c

cp LongGF $PREFIX/


