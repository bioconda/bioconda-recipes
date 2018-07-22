#!/bin/bash
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# schmutzi uses non-standard bamtools functions that aren't part of the normal library
cd ${SRC_DIR}/schmutzi-1.5.5.5/lib
rmdir bamtools
git clone https://github.com/pezmaster31/bamtools
mkdir bamtools/build
cd bamtools/build
cmake ..
make
cd ../..

# Build libgab
rmdir libgab
git clone https://github.com/grenaud/libgab
cd libgab
make BAMTOOLSINC=${PREFIX}/include/bamtools BAMTOOLSLIB=${PREFIX}/lib
cd ../..

make install

# Fix shebangs
sed -i.bak "s:usr/bin/perl:usr/bin/env perl:" *.pl

# There's no "make install"
#binaries=(addXACircular contDeam endoCaller log2fasta mtCont approxDist.R schmutzi.pl mtCont bam2prof insertSize log2freq logs2pos mitoConsPDF.R msa2freq msa2log posteriorDeam.R contOut2ContEst.pl)
#for binary in ${binaries[@]}; do
 #   cp ${binary} ${PREFIX}/bin/
  #  chmod 0755 ${PREFIX}/bin/${binary}
#done
