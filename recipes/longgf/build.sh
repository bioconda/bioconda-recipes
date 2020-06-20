#!/bin/bash

cd LongGF/bin

g++ -g -O3 -std=c++11 -I ./include -L ./lib -Wl,--enable-new-dtags,-rpath,"\$ORIGIN"/lib -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c -Wl,--no-as-needed

cp LongGF $PREFIX/

