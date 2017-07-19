#!/bin/bash

make -j 1
mkdir -p ${PREFIX}/bin

mv tRNAscan-SE coves-SE covels-SE eufindtRNA trnascan-1.4 *.cm -t ${PREFIX}/bin
mv tRNAscanSE ${PREFIX}/bin/.
mv tRNAscan-SE.src ${PREFIX}/bin/.

cd  ${PREFIX}/bin
sed -i "/^use Getopt::Long/c\use Getopt::Long;\\nuse lib ${PREFIX}\/bin\;" tRNAscan-SE
sed -i "/^our \$bindir/c\our bindir = ${PREFIX}\/bin\;" tRNAscan-SE
sed -i "/^our \$lib_dir/c\our lib_dir = ${PREFIX}\/bin\/tRNAscanSE\;" tRNAscan-SE

chmod +x coves-SE
chmod +x covels-SE
chmod +x eufindtRNA
chmod +x trnascan-1.4
chmod +x tRNAscan-SE
