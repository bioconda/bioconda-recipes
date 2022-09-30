#!/bin/bash

mkdir -p ${PREFIX}/bin
# the Makefile uses CC/CFLAGS but it's really C++ code...
unset CXXFLAGS
make -C src CC=${CXX} CFLAGS="-ansi -O2 -fopenmp -fpermissive -I${PREFIX}/include -I. -L${PREFIX}/lib -Wno-deprecated -Wno-write-strings"
cp src/{correct,count-kmers,count-qmers,count_qmers,reduce-kmers,reduce-qmers,trim,build_bithash,correct_stats} ${PREFIX}/bin
cp bin/{cov_model.py,cov_model_qmer.r,cov_model.r,kmer_hist.r,quake.py} ${PREFIX}/bin/
