#!/bin/bash

sed -i "/^BINDIR/c\BINDIR = ${PREFIX}\/bin" Makefile
sed -i "/^LIBDIR/c\LIBDIR = ${PREFIX}\/lib\/tRNAscan-SE" Makefile
sed -i "/^MANDIR/c\MANDIR = ${PREFIX}\/man" Makefile

make -j 1
make install

#mkdir -p ${PREFIX}/bin
#mv tRNAscan-SE coves-SE covels-SE eufindtRNA trnascan-1.4 *.cm -t ${PREFIX}/bin
#mv tRNAscanSE ${PREFIX}/bin/.
#mv tRNAscan-SE.src ${PREFIX}/bin/.

cd  ${PREFIX}/bin
#sed -i "/^use Getopt::Long/c\use Getopt::Long;\\nuse lib ${PREFIX}\/bin\;" tRNAscan-SE
#sed -i "/^our \$bindir/c\our bindir = ${PREFIX}\/bin\;" tRNAscan-SE
#sed -i "/^our \$lib_dir/c\our lib_dir = ${PREFIX}\/bin\/tRNAscanSE\;" tRNAscan-SE

#chmod +x coves-SE
#chmod +x covels-SE
#chmod +x eufindtRNA
#chmod +x trnascan-1.4
#chmod +x tRNAscan-SE
