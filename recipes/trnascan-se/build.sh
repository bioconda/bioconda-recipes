#!/bin/bash

#xport BINDIR=${PREFIX}/bin
#export PERL5LIB=$PERL5LIB:${PREFIX}/lib
#LIBDIR=$(/usr/bin/env perl -V|grep -A1 @INC |tail -n+2)

make -j 1
#make install

mkdir -p ${PREFIX}/bin/tRNAscan-SE
#kdir -p ${PREFIX}/bin/tRNAscan-SE/tRNAscanSE

mv -v tRNAscan-SE coves-SE covels-SE eufindtRNA trnascan-1.4 *.cm -t ${PREFIX}/bin/tRNAscan-SE
mv -v tRNAscanSE ${PREFIX}/bin/tRNAscan-SE/.
mv tRNAscan-SE.src ${PREFIX}/bin/tRNAscan-SE/.

cd  ${PREFIX}/bin/tRNAscan-SE
sed -i "/^use Getopt::Long;/c\use Getopt::Long;\\nuse lib ${PREFIX}/bin/tRNAscan-SE;" tRNAscan-SE
sed -i "/^our \$bindir/c\our bindir = ${PREFIX}/bin/tRNAscan-SE;" tRNAscan-SE
sed -i "/^our \$lib_dir/c\our lib_dir = ${PREFIX}/bin/tRNAscan-SE/tRNAscanSE;" tRNAscan-SE

chmod +x coves-SE 
chmod +x covels-SE 
chmod +x eufindtRNA 
chmod +x trnascan-1.4
chmod +x tRNAscan-SE

#mkdir -p $BINDIR
#

#
#make all 
#
### Build Perl
#
#mkdir perl-build
#mkdir perl-build/lib
#
#find . -name "*.pl" | xargs -I {} mv {} perl-build
#find . -name "*.pm" | xargs -I {} cp {} perl-build/lib
#cd perl-build
#cp ${RECIPE_DIR}/Build.PL ./
#perl ./Build.PL
#perl ./Build manifest
#perl ./Build install --installdirs site
#
#cd ..
### End build perl
#
#mv coves-SE covels-SE eufindtRNA trnascan-1.4 ${PREFIX}/bin
#mv tRNAscan-SE.src ${PREFIX}/bin/tRNAscan-SE
#
#cd ${PREFIX}/bin
#chmod +x coves-SE 
#chmod +x covels-SE 
#chmod +x eufindtRNA 
#chmod +x trnascan-1.4
#chmod +x tRNAscan-SE
