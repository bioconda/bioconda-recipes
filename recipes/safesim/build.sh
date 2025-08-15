#!/bin/bash

# Please note that install-dependencies.sh is skipped because conda already handled the dependencies. 
# We skip fastq-tools because it is defined in the meta.yaml file. 
# We use -with-libdeflate to ensure that htslib does not cause error in the linking stage.
# bash -evx ./install-dependencies.sh skip-fastq-tools -with-libdeflate

make clean || true

# We add -ldeflate to prevent "undefined symbol" error in the linking stage.
# We add CXX and PREFIX to accomodate for conda build env
# We add -fPIE to get compatibility with conda libs
# We do not build debug executables because -fsanitize seems to be in conflict with -fPIE
# Dynamic linking instead of static linking is done to htslib here because if a system can run conda then it should be able to have libhts.so installed. 
make CXX=$CXX CXXFLAGS="-pthread -lm -lz -lbz2 -llzma -static-libstdc++ -lhts -ldeflate -fPIE -I $PREFIX/include" LDFLAGS="-L $PREFIX/lib" safemut safemix 

mkdir -p $PREFIX/bin
cp safemix $PREFIX/bin
cp safemut $PREFIX/bin
