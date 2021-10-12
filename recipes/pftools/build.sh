#!/bin/sh
set -x -e

#compile
#conda install -p $PREFIX libgfortran=3.0 -y
# backup to "gfortran" in conda GFORTRAN is not set
PFTOOLS_PROGRAMS="pfscanV3 pfsearchV3 gtop pfmake pfscan pfw ptoh htop pfscale pfsearch psa2msa 2ft 6ft ptof"
mkdir build
cd build/
cmake ..
make CC=${CC} CXX=${CXX} F77=${GFORTRAN} CFLAGS="$CFLAGS $LDFLAGS"

ls -l

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
done
