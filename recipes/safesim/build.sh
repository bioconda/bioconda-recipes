#!/bin/bash
bash -evx ./install-dependencies.sh skip-fastq-tools -with-libdeflate
make clean || true
make CXXFLAGS="-static-libstdc++ ext/htslib-1.11-lowdep/libhts.a -I ext/htslib-1.11-lowdep/ -pthread -lm -lz -lbz2 -llzma -ldeflate" && make deploy

