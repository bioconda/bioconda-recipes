#!/bin/bash
chmod +x htslib/version.sh
sed -i.bak "4iCFLAGS += -I${PREFIX}/include -L${PREFIX}/lib" pSAscan-0.1.0/src/Makefile

make CC=${CXX} INCLUDES="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
mv psascan ${PREFIX}/bin/
mv bitmapperBS ${PREFIX}/bin/
