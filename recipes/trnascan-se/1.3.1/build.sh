#!/bin/bash

sed -i -e 's/HOME/PREFIX/g' Makefile
make -j 1 CC="${CC}" CFLAGS="${CFLAGS}"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib/tRNAscan-SE
mkdir -p ${PREFIX}/man

mv -f tRNAscan-SE coves-SE covels-SE eufindtRNA* trnascan-1.4* mpcovels* ${PREFIX}/bin
mv -f TPCsignal Dsignal *.cm gcode.* ${PREFIX}/lib/tRNAscan-SE
mv -f tRNAscanSE ${PREFIX}/bin/.
mv -f tRNAscan-SE.src ${PREFIX}/bin/.

cd  ${PREFIX}/bin
export PREFIX=${PREFIX}
perl -i~ -pe 'BEGIN{ $replace = shift } s/use Getopt::Long;/use Getopt::Long;\n$replace/g' "use lib '${PREFIX}/bin';" tRNAscan-SE

chmod +x coves-SE
chmod +x covels-SE
chmod +x eufindtRNA
chmod +x trnascan-1.4
chmod +x tRNAscan-SE
