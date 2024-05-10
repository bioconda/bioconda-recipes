#!/bin/bash

set -ex

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/annotation"

cd src
MAKEFILE=Makefile.Linux
if [ `uname` = "Darwin" ];
then
  MAKEFILE=Makefile.MacOS
fi

if [ $(uname -m) == "aarch64" ]; then
  sed -i.bak 's/-mtune=core2//' ${MAKEFILE}
  sed -i.bak 's/-mtune=core2//' ./longread-one/Makefile
fi

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make -f $MAKEFILE CC_EXEC="$CC -L$PREFIX/lib -fcommon" -j ${CPU_COUNT}
cd ..
cp bin/utilities/* $PREFIX/bin
rm -r bin/utilities
cp bin/* $PREFIX/bin
cp annotation/* $PREFIX/annotation

# add read permissions to LICENSE
chmod a+r LICENSE