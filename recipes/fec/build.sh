#!/usr/bin/env bash

#mkdir -p ${PREFIX}/bin

#mv Fec ${PREFIX}/bin
#chmod +x ${PREFIX}/bin/Fec
sed -i.bak "369,375d" Makefile
make CFLAGS="$CFLAGS -D_GLIBCXX_PARALLEL -pthread -O3 -Wall -std=gnu99" CXXFLAGS="$CXXFLAGS -D_GLIBCXX_PARALLEL -pthread -O3 -Wall -std=c++11"
ls -l
