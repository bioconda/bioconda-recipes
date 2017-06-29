#!/bin/bash


BINDIR=$PREFIX/bin
mkdir -p $BINDIR

LIBDIR=${PREFIX}/lib

make all 

## Build Perl

mkdir perl-build
find . -name "*.pl" | xargs -I {} mv {} perl-build
find . -name "*.pm" | xargs -I {} cp {} perl-build/lib
cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..
## End build perl

mv coves-SE covels-SE eufindtRNA trnascan-1.4 $PREFIX/bin
mv tRNAscan-SE.src $PREFIX/bin/tRNAscan-SE

cd $PREFIX/bin
chmod +x coves-SE 
chmod +x covels-SE 
chmod +x eufindtRNA 
chmod +x trnascan-1.4
chmod +x tRNAscan-SE



