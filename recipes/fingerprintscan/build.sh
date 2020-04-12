#!/bin/sh
set -x -e

export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

PROGRAMS="fingerPRINTScan"

#patch - shuffle conflicts with a function in the STL
sed -i'' -e 's/shuffle/ShuffleFlag/g' FingerPrint.cc

#compile
LD_LIBRARY_PATH=${LD_LIBRARY_PATH} CPPFLAGS="${CPPFLAGS} -Wno-write-strings" LDFLAGS=${LDFLAGS} CXX=${CXX} ./configure

make
make check
make install

#for debug
ls -l

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done
