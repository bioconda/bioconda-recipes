#!/bin/bash

cd bin

g++ -g -O3 -std=c++11 -I $PREFIX/include -L $PREFIX/lib -Wl,--enable-new-dtags -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c -Wl,--no-as-needed

cp LongGF $PREFIX/


