#!/bin/bash
# We skip fastq-tools because it is defined in the meta.yaml
# We use -with-libdeflate to ensure that htslib does not cause error in the linking stage
bash -evx ./install-dependencies.sh skip-fastq-tools -with-libdeflate
make clean || true
# We add -ldeflate to prevent "undefined symbol" error in the linking stage.
# We add CXX and PREFIX to accomodate for conda build env
# We add -fPIE to get compatibility with conda libs
# We do not build debug executables because -fsanitize seems to be in conflict with -fPIE
make CXX=$CXX CXXFLAGS="-static-libstdc++ ext/htslib-1.11-lowdep/libhts.a -I ext/htslib-1.11-lowdep/ -I $PREFIX/include -pthread -lm -lz -lbz2 -llzma -ldeflate -fPIE" LDFLAGS="-L $PREFIX/lib" safemut safemix 
make deploy

