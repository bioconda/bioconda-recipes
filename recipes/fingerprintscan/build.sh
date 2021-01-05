#!/bin/sh
set -x -e

export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

PROGRAMS="fingerPRINTScan"

#compile
LD_LIBRARY_PATH=${LD_LIBRARY_PATH} CPPFLAGS="${CPPFLAGS} -Wno-write-strings" LDFLAGS=${LDFLAGS} CXX=${CXX} ./configure

make
make check

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done
