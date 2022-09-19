#!/bin/bash
# We skip fastq-tools because it is defined in the meta.yaml
# We use -with-libdeflate to ensure that htslib does not cause error in the linking stage
bash -evx ./install-dependencies.sh skip-fastq-tools -with-libdeflate
make clean || true
# We added -ldeflate to prevent "undefined symbol" error in the linking stage.
make CXX=$CXX CXXFLAGS="-static-libstdc++ ext/htslib-1.11-lowdep/libhts.a -I ext/htslib-1.11-lowdep/ -I $PREFIX/include -pthread -lm -lz -lbz2 -llzma -ldeflate" LDFLAGS="-L $PREFIX/lib" && make deploy

