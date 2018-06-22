#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/annotation"

export C_INCLUDE_PATH="${PREFIX}/include"
cd src
if [ `uname` = "Darwin" ];
then
  MAKEFILE=Makefile.MacOS
  sed -i.bak "371" $MAKEFILE
else
  MAKEFILE=Makefile.Linux
  sed -i.bak "37d" $MAKEFILE
fi
cd longread-one
touch make.version
make CC_EXEC=$CC LDFLAGS="-lpthread -lz -lm -O3 -DMAKE_FOR_EXON -D MAKE_STANDALONE -L${PREFIX}/lib"
cd ..
make -f $MAKEFILE CC_EXEC=$CC STATIC_MAKE="-L${PREFIX}/lib"
cd ..
cp bin/utilities/* $PREFIX/bin
rm -r bin/utilities
cp bin/* $PREFIX/bin
cp annotation/* $PREFIX/annotation
