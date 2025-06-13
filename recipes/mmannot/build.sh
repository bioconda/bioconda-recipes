#!/bin/bash

# zlib hack
make CXX=$CXX INCLUDES="-I$PREFIX/include" CFLAGS+="-L$PREFIX/lib"
chmod +x mmannot
chmod +x addNH
mkdir -p ${PREFIX}/bin
cp -f mmannot ${PREFIX}/bin
cp -f addNH ${PREFIX}/bin
