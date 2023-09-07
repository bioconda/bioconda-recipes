#!/bin/sh
cd Zoe
make CC=${CC} CFLAGS="$CFLAGS -fcommon" zoe-loop
cd ..
make CC=${CC} CFLAGS="$CFLAGS -fcommon" snap
make CC=${CC} CFLAGS="$CFLAGS -fcommon" fathom
make CC=${CC} CFLAGS="$CFLAGS -fcommon" forge
make CC=${CC} CFLAGS="$CFLAGS -fcommon" hmm-info
make CC=${CC} CFLAGS="$CFLAGS -fcommon" exonpairs

mkdir -p $PREFIX/bin
mkdir -p ${PREFIX}/share/snap
mkdir -p ${PREFIX}/share/snap/bin
for perl_script in cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl; do
  sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${perl_script}
done
cp -p snap fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl $PREFIX/share/snap/bin
cp -pr HMM ${PREFIX}/share/snap
cp -pr DNA ${PREFIX}/share/snap

for NAME in snap fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl ; do
  cp $RECIPE_DIR/wrapper ${PREFIX}/bin/${NAME}
done
chmod a+x ${PREFIX}/bin/*
chmod a+x ${PREFIX}/share/snap/bin/*
