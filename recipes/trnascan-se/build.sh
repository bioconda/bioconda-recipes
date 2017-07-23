#!/bin/bash

sed -i "/^BINDIR/c\BINDIR = ${PREFIX}\/bin" Makefile
sed -i "/^LIBDIR/c\LIBDIR = ${PREFIX}\/lib\/tRNAscan-SE" Makefile
sed -i "/^MANDIR/c\MANDIR = ${PREFIX}\/man" Makefile

make -j 1

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib/tRNAscan-SE
mkdir -p ${PREFIX}/man

mv -f tRNAscan-SE coves-SE covels-SE eufindtRNA* trnascan-1.4* mpcovels* -t ${PREFIX}/bin
mv -f TPCsignal Dsignal *.cm gcode.* -t ${PREFIX}/lib/tRNAscan-SE
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
