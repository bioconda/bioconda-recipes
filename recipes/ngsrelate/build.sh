#! /bin/bash

mkdir -p ${PREFIX}/bin

make HTSSRC="${PREFIX}" CC="$CC" CXX="$CXX" FLAGS="-I${PREFIX}/include -L${PREFIX}/lib"

chmod +x ngsRelate
cp ngsRelate ${PREFIX}/bin/
